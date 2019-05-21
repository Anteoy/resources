---
id: 105
date: 2019-05-21 12:33:20
title: java golang tcp socket导致线上服务器出现大量close_wait的完整示例
categories:
    - java
tags: 
    - java,string,golang,socket,close_wait
---


### tcp断开连接的四次挥手

先说说tcp的四次挥手，这里假定A端为主动发起关闭端，B端为被动接收关闭请求端。A把tcp的数据包中标识位FIN置为1，seq为一个随机数，发送这个包给B端，自己进入FIN_WAIT_1状态；B端收到了马上给A端回复ack（A端收到ack进入FIN_WAIT_2状态），然后自己进入CLOSE_WAIT状态。然后这个时候需要业务代码处理，把自己需要发给客户端的数据发送完，然后业务代码主动调用相应语言库函数提供的close函数，来触发关闭操作:给A端发送FIN seq的数据包，这是第三次握手。这个时候自己进入last ack状态。 A端此时收到包然后给B端口发送相应ack.A端自己此时进入time_wait状态。 B端收到ack后从last_ack就顺利进入close状态了。A端等到timewait 2msl时间后（这个时间不同的操作系统的设置不同，大约是2分钟），自动进入close状态。

如果在B端不主动调用相应自己语言的close函数，那么就会一直处于close wait状态。大量socket连接不能正常释放。直到socket服务器端打开的文件数超过系统的最大限制数，其他连接无法正常建立连接，建立连接的时候抛出too many open files异常

网上搜索的图，便于理解（侵删）

![http://oss.allocmem.com/blog/tcp_fin.jpg](http://oss.allocmem.com/blog/tcp_fin.jpg)

### linux 统计tcp连接的各种状态的连接数

这里每5秒输出一次 可以修改为自己想要的时间
```
 while true ;do  netstat -n | awk '/^tcp/ {++S[$NF]} END {for(a in S) print a, S[a]}' && print '-------------' ; sleep 5; done;
```

### java版本的完整复现代码

只需要把Server.java中socket.close();这行注释掉就能观察到系统的close_wait 状态的tcp连接会一直无法释放，而打开这行注释，tcp连接即可正常关闭

Server.java

```
/**
 * @auther zhoudazhuang
 * @date 19-5-20 17:44
 * @description
 */

import java.io.*;
import java.net.ServerSocket;
import java.net.Socket;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Phaser;


public class Server {
    static class Worker implements Runnable {
        Socket socket;
        Phaser phaser;
        Worker(Socket socket,Phaser phaser){
            this.socket = socket;
            this.phaser = phaser;
        }
        @Override
        public void run() {
            try {
                //获取输入流，并读入客户端的信息
                InputStream in = socket.getInputStream(); //字节输入流
                Thread.sleep(3000);
                InputStreamReader inreader = new InputStreamReader(in); //把字节输入流转换为字符流
                BufferedReader br = new BufferedReader(inreader); //为输入流添加缓冲
                String info;
                PrintWriter printWriter;
                OutputStream outputStream;
                //readline \n
                while((info = br.readLine())!=null){
                    System.out.println("收到客户端发送的消息："+info);
                    //获取输出流，相应客户端的信息
                    outputStream = socket.getOutputStream();
                    printWriter = new PrintWriter(outputStream);//包装为打印流
                    printWriter.write("来自服务端的消息！\n");
                    printWriter.flush(); //刷新缓冲
                    if (info.equals("shutdown")){
                        // 等待客户端断开连接
                        System.out.println("服务端进入关闭等待状态...");
                        Thread.sleep(1000*30);
//                      socket.shutdownInput();//关闭输入流
//                      socket.shutdownOutput();
                        //关闭资源
//                      printWriter.close();
//                      outputStream.close();
//                      br.close();
//                      inreader.close();
//                      in.close();
                        //打开注释则正常关闭 否则服务端会出现大量的close_wait状态
                        socket.close();
                        System.out.println("服务端完成等待状态...");
                        break;
                    }
                }
                // 需要观察 不能让线程执行完毕
                System.out.println("服务端线程进行休眠，为了观察close_wait...");
                Thread.sleep(1000 * 60 * 30);
                System.out.println("服务端线程执行完毕，即将退出");
            } catch (IOException e) {
                e.printStackTrace();
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
        }
    }

    public static void main(String[] args) throws InterruptedException {

        ExecutorService executorService = Executors.newFixedThreadPool(1000);
        Phaser phaser = new Phaser();
        try  {
            //创建一个服务器socket，即serversocket,指定绑定的端口，并监听此端口
            ServerSocket serverSocket = new ServerSocket(8888);
            //调用accept()方法开始监听，等待客户端的连接
            System.out.println("***服务器即将启动，等待客户端的连接***");
            while (true) {
                Socket socket = serverSocket.accept();
                executorService.execute(new Worker(socket,phaser));
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}
```

Client.java

```
import java.io.*;
import java.net.Socket;

/**
 * @auther zhoudazhuang
 * @date 19-5-20 17:45
 * @description
 */
public class Client {
    public static void main(String[] args) {
        for (int i = 0; i< 1000; i++) {
      new Thread(
              () -> {
                // 创建客户端socket建立连接，指定服务器地址和端口
                try {
                  Socket socket = new Socket("127.0.0.1", 8888);
                  // 获取输出流，向服务器端发送信息
                  OutputStream outputStream = socket.getOutputStream(); // 字节输出流
                  PrintWriter pw = new PrintWriter(outputStream); // 将输出流包装为打印流
                  pw.write("shutdown\n");
                  pw.flush();
                  // 获取输入流，读取服务器端的响应
                  InputStream inputStream = socket.getInputStream();
                  BufferedReader br = new BufferedReader(new InputStreamReader(inputStream));
                  String info = null;
                  while ((info = br.readLine()) != null) {
                    System.out.println("收到服务端发送过来的消息：" + info);

                    // 关闭资源
                    // 20s后主动关闭连接
                    Thread.sleep(1000 * 20);
                    System.out.println("开始关闭。。。");
                    //socket.shutdownInput();
                    //socket.shutdownOutput();
                    br.close();
                    inputStream.close();
                    pw.close();
                    outputStream.close();
                    socket.close();
                    System.out.println("client完成关闭 线程不退出 进行睡眠 否则影响评估 线程没了这边的main执行完成，则服务端会直接断开，因为客户端不在了");
                    Thread.sleep(1000 * 60 * 10);
                    System.out.println("客户端线程执行完毕");
                    // 关闭连接后跳出while循环 否则java.io.IOException: Stream closed
                    break;
                  }
                  // 需要观察 不能让线程执行完毕
                  System.out.println("客户端线程进行休眠，为了观察close_wait...");
                  Thread.sleep(1000 * 60 * 30);
                  System.out.println("客户端线程执行完毕，即将退出");

                } catch (IOException e) {
                  e.printStackTrace();
                } catch (InterruptedException e) {
                  e.printStackTrace();
                }
              })
          .start();
        }
    }
}
```

### golang版本的完整复现代码

只需要把c.Close()这行代码注释掉以及打开注释 然后使用上面的命令行则能直接观察到效果

server.go

```
package main

import (
	"fmt"
	"net"
	"time"
)

func main() {
	// tcp 监听并接受端口
	l, err := net.Listen("tcp", "127.0.0.1:65535")
	if err != nil {
		fmt.Println(err)
		return
	}
	//最后关闭
	defer l.Close()
	fmt.Println("tcp服务端开始监听65535端口...")
	// 使用循环一直接受连接
	for {
		//Listener.Accept() 接受连接
		c, err := l.Accept()
		if err != nil {
			return
		}
		//处理tcp请求
		go handleConnection(c)
	}
}

func handleConnection(c net.Conn) {
	//一些代码逻辑...
	fmt.Println("tcp服务端开始处理请求...")
	//读取
	buffer := make([]byte, 1024)
	//如果客户端无数据则会阻塞
	c.Read(buffer)

	//输出buffer
	c.Write(buffer)
	fmt.Println("tcp服务端开始处理请求完毕...")
	time.Sleep(40 * time.Second)
	//c.Close()
	fmt.Println("服务端开始close")
}

```

client.go

```
package main

import (
	"fmt"
	"net"
	"sync"
	"time"
)

func main() {
	wg := sync.WaitGroup{}
	for i := 0; i < 1000; i++ {
		wg.Add(1)
		go func() {
			//net.dial 拨号 获取tcp连接
			conn, err := net.Dial("tcp", "127.0.0.1:65535")
			if err != nil {
				fmt.Println(err)
				return
			}
			fmt.Println("获取127.0.0.1：65535的tcp连接成功...")
			defer conn.Close()
			defer wg.Done()

			//需要放在read前面，输出到服务端，否则服务端阻塞
			conn.Write([]byte("echo data to server ,then to client!!!"))

			//读取到buffer
			buffer := make([]byte, 1024)
			conn.Read(buffer)
			fmt.Println(string(buffer))
			time.Sleep(30 * time.Second)
			conn.Close()
			//便于观察
			time.Sleep(30 * time.Minute)
		}()
	}

	wg.Wait()
	fmt.Println("全部完成")

}

```

### 输出

无法正常关闭会一直循环输出:（每台服务器的输出不会相同，大致如下）

```
CLOSE_WAIT 1009
ESTABLISHED 25
SYN_SENT 118
```

正常关闭的循环输出：（每台服务器的输出不会相同，大致如下）

```
TIME_WAIT 1000
ESTABLISHED 24
LAST_ACK 1
SYN_SENT 77
```
这里的time_wait状态会逐渐消失