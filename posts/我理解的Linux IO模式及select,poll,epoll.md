---
id: 94
date: 2018-04-21 13:30:00
title: 我理解的Linux IO模式及select,poll,epoll
categories:
    - linux
tags:
    - Linux IO,select,poll,epoll
---

### 前言

本文是在本人查阅部分资料，并综合了众多博客分析后，于此阐述的个人理解。若有错误，欢迎指正。

### 基本概念

1. 用户空间和内核空间   
操作系统核心-内核负责处理用户程序和硬件之间的驱动交互。内核是在用户程序（进程）和硬件之间一个中枢。目地：专门负责用户进程和硬件之间的交互，用户程序必须使用内核才能和计算机底层硬件进行交流。为了保证内核的安全，于是将内存划分开，比如针对linux 4G的内存空间，将最高的1G字节（从虚拟地址0xC0000000到0xFFFFFFFF），供内核使用，称为内核空间，而将较低的3G字节（从虚拟地址0x00000000到0xBFFFFFFF），供各个进程使用，称为用户空间。

2. 进程切换   
内核操作CPU上运行的进程，比如把正在CPU上运行的A进程切换为B进程，让另外一个进程等待。   
	
	> 从一个进程的运行转到另一个进程上运行，这个过程中经过下面这些变化:
	> 1. 保存处理机上下文，包括程序计数器和其他寄存器。
	> 2. 更新PCB信息。
	> 3. 把进程的PCB移入相应的队列，如就绪、在某事件阻塞等队列。
	> 4. 选择另一个进程执行，并更新其PCB。
	> 5. 更新内存管理的数据结构。
	> 6. 恢复处理机上下文。   
**十分消耗资源**   
3. 进程的阻塞   
	> 正在执行的进程，由于期待的某些事件未发生，如请求系统资源失败、等待某种操作的完成、新数据尚未到达或无新工作做等，则由系统自动执行阻塞原语(Block)，使自己由运行状态变为阻塞状态。可见，进程的阻塞是进程自身的一种主动行为，也因此只有处于运行态的进程（获得CPU），才可能将其转为阻塞状态。当进程进入阻塞状态，是不占用CPU资源的。   
4. 套接字和文件描述符   
linux哲学--一切皆文件。
为了区别不同的应用程序进程和连接，许多计算机操作系统为应用程序与TCP/IP协议交互提供了称为套接字(Socket)的接口。
linux以文件的形式实现套接口，与套接口相应的文件属于sockfs特殊文件系统，创建一个套接口就是在sockfs中创建一个特殊文件，并建立起为实现套接口功能的相关数据结构。换句话说，对每一个新创建的套接字，linux内核都将在sockfs特殊文件系统中创建一个新的inode。   
部分概念：   

	- 一个TCP连接的套接字对（socket pair）是一个定义该连接的两个端点的四元组：本地IP地址、本地TCP端口、外地地址、外地TCP端口。套接字对唯一标识一个网络上的每个TCP连接。
	标识每个端口的两个值（IP地址和端口号）通常称为一个套接字。
	- 内核（kernel）利用文件描述符（file descriptor）来访问文件。文件描述符是非负整数。打开现存文件或新建文件时，内核会返回一个文件描述符。读写文件也需要使用文件描述符来指定待读写的文件。
	- 套接字和文件描述符有什么不同？
	套接字是一个抽象出来的概念，本质上也是一个文件描述符。   

5. 缓存 I/O   

> 缓存 I/O 又被称作标准 I/O，大多数文件系统的默认 I/O 操作都是缓存 I/O。在 Linux 的缓存 I/O 机制中，操作系统会将 I/O 的数据缓存在文件系统的页缓存（ page cache ）中，也就是说，数据会先被拷贝到操作系统内核的缓冲区中，然后才会从操作系统内核的缓冲区拷贝到应用程序的地址空间。

> 缓存 I/O 的缺点：
> 数据在传输过程中需要在应用程序地址空间和内核进行多次数据拷贝操作，这些数据拷贝操作所带来的 CPU 以及内存开销是非常大的。   

### Linux IO模式

**对于一次IO访问（以read举例），数据会先被拷贝到操作系统内核的缓冲区中，然后才会从操作系统内核的缓冲区拷贝到应用程序的地址空间。**

- 等待数据准备 (Waiting for the data to be ready) 比如等待网络数据下载完毕加载到内核内存空间
- 将数据从内核拷贝到进程中 (Copying the data from the kernel to the process)

Linux IO 5模式（根据上面两个步骤）：   

- 阻塞 I/O（blocking IO）
- 非阻塞 I/O（nonblocking IO）
- I/O 多路复用（ IO multiplexing）
- 信号驱动 I/O（ signal driven IO）
- 异步 I/O（asynchronous IO）

#### 阻塞 I/O（blocking IO）

在linux中，默认情况下所有的socket都是blocking（select,poll,epoll需要程序自己实现循环listen）。
recvfrom发起system call系统调用，然后等待内核处理。recvfrom发起一次。
**blocking IO的特点就是在IO执行的两个阶段都被block了。**

#### 非阻塞 I/O（nonblocking IO）

recvfrom发起system call系统调用，然后等待内核处理。recvfrom发起不止一次，进行轮循调用。

**nonblocking IO的特点是用户进程需要不断的主动询问kernel数据好了没有。**

#### I/O 多路复用（ IO multiplexing）

IO multiplexing就是我们说的select，poll，epoll，有些地方也称这种IO方式为event driven IO。

**原理：select，poll，epoll这些system call function会不断的轮询所负责的所有socket，当某个socket有数据到达了，（就发起系统调用），kernel io获取完毕后用事件通知的方式通知用户进程。然后用户进程收到通知后，再用recvfrom发起一次系统调用，请求拷贝数据到用户内存，完成后内核会再发一个通知给用户，recvfrom发起后拷贝数据也是阻塞的，这里要注意**

**I/O 多路复用的特点是通过一种机制一个进程能同时等待多个文件描述符（多个连接），而这些文件描述符（套接字描述符，多个连接）其中的任意一个进入读就绪状态，select()函数就可以返回。（然后执行业务逻辑）**

这里需要使用两个system call (select 和 recvfrom)，而blocking IO只调用了一个system call (recvfrom)。但是，用select的优势在于它可以同时处理多个connection(处理高并发连接)。

#### 异步 I/O（asynchronous IO）

**没有recvfrom调用，完全异步，没有在revcfrom进行系统复制调用的时候，阻塞自身**

> 用户进程发起read操作之后，立刻就可以开始去做其它的事。而另一方面，从kernel的角度，当它受到一个asynchronous read之后，首先它会立刻返回，所以不会对用户进程产生任何block。然后，kernel会等待数据准备完成，然后将数据拷贝到用户内存，当这一切都完成之后，kernel会给用户进程发送一个signal，告诉它read操作完成了。

#### 小结
1. blocking和non-blocking的区别

	调用blocking IO会一直block住对应的进程直到操作完成，而non-blocking IO在kernel还准备数据的情况下会立刻返回。

2. synchronous IO和asynchronous IO的区别

	> 两者的区别就在于synchronous IO做”IO operation”的时候会将process阻塞。按照这个定义，之前所述的blocking IO，non-blocking IO，IO multiplexing都属于synchronous IO。

	> 有人会说，non-blocking IO并没有被block啊。这里有个非常“狡猾”的地方，定义中所指的”IO operation”是指真实的IO操作，就是例子中的recvfrom这个system call。non-blocking IO在执行recvfrom这个system call的时候，如果kernel的数据没有准备好，这时候不会block进程。但是，当kernel中数据准备好的时候，recvfrom会将数据从kernel拷贝到用户内存中，这个时候进程是被block了，在这段时间内，进程是被block的。

	> 而asynchronous IO则不一样，当进程发起IO 操作之后，就直接返回再也不理睬了，直到kernel发送一个信号，告诉进程说IO完成。在这整个过程中，进程完全没有被block。

### I/O 多路复用之select、poll、epoll


定义：   
前提:
select，poll，epoll都是IO多路复用的机制。I/O多路复用就是通过一种机制，一个进程可以监视多个描述符，一旦某个描述符就绪（一般是读就绪或者写就绪），能够通知程序进行相应的读写操作。但select，poll，epoll本质上都是同步I/O，因为他们都需要在读写事件就绪后自己负责进行读写，也就是说这个读写过程是阻塞的，而异步I/O则无需自己负责进行读写，异步I/O的实现会负责把数据从内核拷贝到用户空间。

1. select   
  相关system call kernel func：   
  ```
  int select (int n, fd_set *readfds, fd_set *writefds, fd_set *exceptfds, struct timeval *timeout);
  ```   
  select 函数监视的文件描述符分3类，分别是writefds、readfds、和exceptfds。  
  select目前几乎在所有的平台上支持，其良好跨平台支持也是它的一个优点。select的一 个缺点在于单个进程能够监视的文件描述符的数量存在最大限制，在Linux上一般为1024，可以通过修改宏定义甚至重新编译内核的方式提升这一限制，但 是这样也会造成效率的降低。
2. poll   
  相关system call kernel func：   
  ```
  int poll (struct pollfd *fds, unsigned int nfds, int timeout);
  ```   
  不同与select使用三个位图来表示三个fdset的方式，poll使用一个 pollfd的指针实现。pollfd并没有最大数量限制（但是数量过大后性能也是会下降）。 和select函数一样，poll返回后，需要轮询pollfd来获取就绪的描述符。   
  ```
  struct pollfd {
    int fd; /* file descriptor */
    short events; /* requested events to watch */
    short revents; /* returned events witnessed */
  };
  ```   
  **select和poll都需要在返回后，通过遍历文件描述符来获取已经就绪的socket。事实上，同时连接的大量客户端在一时刻可能只有很少的处于就绪状态，因此随着监视的描述符数量的增长，其效率也会线性下降。**
3. epoll   
  相关system call kernel func（epoll使用一组函数来完成任务，而不是单个函数）：
  ```
  int epoll_create(int size)；//创建一个epoll的句柄，size用来告诉内核这个监听的数目一共有多大
int epoll_ctl(int epfd, int op, int fd, struct epoll_event *event)；
int epoll_wait(int epfd, struct epoll_event * events, int maxevents, int timeout);
  ```   
  > 在 select/poll中，进程只有在调用一定的方法后，内核才对所有监视的文件描述符进行扫描，而epoll事先通过epoll_ctl()来注册一 个文件描述符，一旦基于某个文件描述符就绪时，内核会采用类似callback的回调机制，迅速激活这个文件描述符，当进程调用epoll_wait() 时便得到通知。(此处去掉了遍历文件描述符，而是通过监听回调的的机制。这正是epoll的魅力所在。)
 epoll的优点主要是一下几个方面：
   
   1. 监视的描述符数量不受限制，它所支持的FD上限是最大可以打开文件的数目（它所支持的FD上限是最大可以打开文件的数目。具体数目可以cat /proc/sys/fs/file-max察看,一般来说这个数目和系统内存关系很大。我的系统的file-max值是1216107。）,select的最大缺点就是进程打开的fd是有数量限制的。这对 于连接数量比较大的服务器来说根本不能满足,为什么select在linux上有1024 open的限制呢？select使用位域的方式来传递关心的文件描述符，位域就有最大长度，在Unix下是256，在Linux下是1024（由FD_SETSIZE设置）。

    2. IO的效率不会随着监视fd的数量的增长而下降。epoll不同于select和poll轮询的方式，而是通过每个fd定义的回调函数来实现的。只有就绪的fd才会执行回调函数。（epoll把用户关心的文件描述符上的事件放在内核里的一个事件表中，从而无须像select和poll那样每次调用都要重复传入文件描述符集或事件集。 ）
    
### 参考
1. [http://www.cnblogs.com/web21/p/6520164.html](http://www.cnblogs.com/web21/p/6520164.html)
2. [https://blog.csdn.net/daiyudong2020/article/details/51864722](https://blog.csdn.net/daiyudong2020/article/details/51864722)
3. [https://segmentfault.com/a/1190000003063859](https://segmentfault.com/a/1190000003063859)
4. [https://blog.csdn.net/fengxinlinux/article/details/75452740](https://blog.csdn.net/fengxinlinux/article/details/75452740)
5. [https://www.zhihu.com/question/37219281](https://www.zhihu.com/question/37219281)
