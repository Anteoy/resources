---
id: 80
date: 2019-03-22 17:53:50
title: java和golang中的unsafe包
categories:
    - java
tags:
    - java jvm 字节存储 中间件
---

### 首先聊聊反射    
java和golang都有各自的反射机制，为什么标准库会提供反射机制呢？    
反射（reflection）允许程序在运行时（runtime）检查、修改程序（比如对象,struct等）的结构与行为，跳过编译检查，越过访问权限，运行时对象生成，方法调用等。如果没有反射，那么需要完全手动进行硬编码，比如如果没有反射，那么在spring的ioc容器管理实现就需要我们使用new来创建对象，那么也就不叫spring ioc，不会有spring ioc的诞生了。
静态编译（多数静态语言）：在编译时确定类型，绑定对象。 
动态编译（多数动态语言）：运行时确定类型，绑定对象。可以实现动态创建对象和编译，体现出很大的灵活性（特别是在J2EE的开发中它的灵活性就表现的十分明显）。通过反射机制我们可以获得类的各种内容。对于java以及golang这种先编译再运行的语言来说，反射机制可以使代码更加灵活，更加容易实现面向对象。
### 反射的实现
在java和golang的反射实现中，主要依赖于对象指针（也就是对象的内存地址），以及编译时已链接到对象上的强类型信息。    
BTW，在java语言的反射Method.invoke方法调用实现中，默认为委派实现，委派给本地方法来进行方法调用。在调用超过15次之后，委派实现便会将委派对象切换至动态实现(自己动态生成字节码)，动态实现和本地实现相比，其运行效率要快上20倍，因为本地实现需要先调c++本地实现，然后c++的返回再用java接收，所以是比较耗时的。另外，生成动态实现的字节码也是比较耗时的，当然生成动态调用的字节码只生成一次，生成后就可以多次调用。
### 为何需要unsafe    
在golang的标准包中，提供了unsafe操作（unsafe.go），通过主要用于对内存指针的操作，普通对象指针通过转化为unsafe.Pointer，而unsafe.Pointer可以转化为uintptr，uintptr支持指针相关的内存操作，通过unsafe包，间接的实现了直接指针内存相关的操作.    
而在java的标准包中，并没有提供unsafe包，unsafe包存在于sun.msic下的Unsafe.java类,misc即miscellaneous混杂的意思，因为unsafe会破坏java倡导的内存安全，所以一直没有并入标准包，另外，oracle目前在主导unsafe包的移除和替换工作，java中的unsafe包，同样提供了基于内存地址的相关操作，除了操作GC能回收的堆内存，还能操作GC无法回收的区域--堆外内存，可以直接对内存地址的值进行操作，新建的对象需要自己手动free释放内存，目前的线程挂起和恢复，cas原子操作，类实例化以及基于内存偏移地址的修改，在许多的库中有广泛的使用，比如java中整个并发框架中对线程的挂起操作被封装在 LockSupport类中，LockSupport类中有各种版本pack方法，但最终都调用了Unsafe.park()方法。java的unsafe包主要可以提高程序的运行性能，以及可以减少GC的垃圾回收停顿时间，对一些java应用性能要求较高的应用，提供了除JNI C++调用之外的另一种选择

### java unsafe参考示例

1. 实例化私有类
正常情况下没法实例化一个私有构造函数的类，但通过反射或unsafe可以做到。区别在于unsafe不会调用构造函数初始化，以及成员变量的初始化，如下：

```
package com.anteoy.coreJava.unsafe;

import sun.misc.Unsafe;

import java.lang.reflect.Field;

/**
 * @auther zhoudazhuang
 * @date 19-3-22 12:51
 * @description
 */
public class Uncover {
    public static void main(String[] args) throws IllegalAccessException, InstantiationException, NoSuchFieldException {
        Field f = null;
        f = Unsafe.class.getDeclaredField("theUnsafe");
        f.setAccessible(true);
        Unsafe unsafe = (Unsafe) f.get(null);
        System.out.println(unsafe);
        test2(unsafe);


    }

    static void test1(Unsafe unsafe) throws IllegalAccessException, InstantiationException {
        A o1 = new A(); // constructor
        System.out.println(o1.a()); // prints 1

        A o2 = A.class.newInstance(); // reflection
        System.out.println(o2.a()); // prints 1

        // 不会赋值 不会初始化不会构造函数
        A o3 = (A) unsafe.allocateInstance(A.class); // unsafe
        System.out.println(o3.a());// prints 0
    }

    static void test2(Unsafe unsafe) throws NoSuchFieldException {
        Guard guard = new Guard();
        guard.giveAccess();   // false, no access

        // bypass
        Field f = guard.getClass().getDeclaredField("ACCESS_ALLOWED");
        //过内存偏移地址修改变量值
        unsafe.putInt(guard, unsafe.objectFieldOffset(f), 42); // memory corruption
        guard.giveAccess(); // true, access granted
    }
}

class A {
    private long a = 10; // not initialized value

    public A() {
    System.out.println("init");
        this.a = 1; // initialization
    }

    public long a() { return this.a; }
}


class Guard {
    private int ACCESS_ALLOWED = 1;

    public boolean giveAccess() {
    System.out.println(42 == ACCESS_ALLOWED);
        return 42 == ACCESS_ALLOWED;
    }
}

```

2. cas原子级操作&&通过内存偏移地址修改变量值    
注意代码中的对应的内存偏移地址，需要根据打印出的地址自己调整，因为可能因为操作系统不一致，导致内存地址的偏移量不相同

```
package com.anteoy.coreJava.unsafe;

import sun.misc.Unsafe;

import java.lang.reflect.Field;

/**
 * @auther zhoudazhuang
 * @date 19-3-22 17:05
 * @description
 */
public class UnsafePlayer {

    public static void main(String[] args) throws Exception {
        //通过反射实例化Unsafe
        Field f = Unsafe.class.getDeclaredField("theUnsafe");
        f.setAccessible(true);
        Unsafe unsafe = (Unsafe) f.get(null);

        //实例化Player
        Player player = (Player) unsafe.allocateInstance(Player.class);
        player.setAge(18);
        player.setName("li lei");
        for(Field field:Player.class.getDeclaredFields()){
            System.out.println(field.getName()+":对应的内存偏移地址"+unsafe.objectFieldOffset(field));
        }
        System.out.println("-------------------");

        int ageOffset= 12;
        //修改内存偏移地址为12的值（age）,返回true,说明通过内存偏移地址修改age的值成功
        System.out.println(unsafe.compareAndSwapInt(player, ageOffset, 18, 20));
        System.out.println("age修改后的值："+player.getAge());
        System.out.println("-------------------");

        //修改内存偏移地址为12的值，但是修改后不保证立马能被其他的线程看到。
        unsafe.putOrderedInt(player, 12, 33);
        System.out.println("age修改后的值："+player.getAge());
        System.out.println("-------------------");

        //修改内存偏移地址为12的值，volatile修饰，修改能立马对其他线程可见
        unsafe.putObjectVolatile(player, 12, "han mei");
        System.out.println("name修改后的值："+unsafe.getObjectVolatile(player, 12));
    }
}

class Player{

    private int age;

    private String name;

    private Player(){}

    public String getName() {
        return name;
    }
    public void setName(String name) {
        this.name = name;
    }

    public int getAge() {
        return age;
    }

    public void setAge(int age) {
        this.age = age;
    }

}
```

3. 阻塞和恢复

```
package com.anteoy.coreJava.unsafe;

/**
 * @auther zhoudazhuang
 * @date 19-3-22 17:24
 * @description
 */
import java.util.concurrent.locks.LockSupport;

public class Lock {

    public static void main(String[] args) throws InterruptedException {

        ThreadPark threadPark = new ThreadPark();
        threadPark.start();
        ThreadUnPark threadUnPark = new ThreadUnPark(threadPark);
        threadUnPark.start();
        //等待threadUnPark执行成功
        threadUnPark.join();
        System.out.println("运行成功....");
    }


    static  class ThreadPark extends Thread{

        public void run(){
            System.out.println(Thread.currentThread() +"我将被阻塞在这了60s....");
            //阻塞60s，单位纳秒  1s = 1000000000
            LockSupport.parkNanos(1000000000l*60);

            System.out.println(Thread.currentThread() +"我被恢复正常了....");
        }
    }

    static  class ThreadUnPark extends Thread{

        public Thread thread = null;

        public ThreadUnPark(Thread thread){
            this.thread = thread;
        }
        public void run(){

            System.out.println("提前恢复阻塞线程ThreadPark");
            //恢复阻塞线程
            LockSupport.unpark(thread);

        }
    }
}
```

### golang unsafe参考示例
1. 通过指针修改结构体字段

```
package main

import (
	"fmt"
	"unsafe"
)

func main() {
	s := struct {
		a byte
		b byte
		c byte
		d int64
	}{0, 0, 0, 0}

	// 将结构体指针转换为通用指针
	p := unsafe.Pointer(&s)
	// 保存结构体的地址备用（偏移量为 0）
	up0 := uintptr(p)
	// 将通用指针转换为 byte 型指针
	pb := (*byte)(p)
	// 给转换后的指针赋值
	*pb = 10
	// 结构体内容跟着改变
	fmt.Println(s)

	// 偏移到第 2 个字段
	up := up0 + unsafe.Offsetof(s.b)
	// 将偏移后的地址转换为通用指针
	p = unsafe.Pointer(up)
	// 将通用指针转换为 byte 型指针
	pb = (*byte)(p)
	// 给转换后的指针赋值
	*pb = 20
	// 结构体内容跟着改变
	fmt.Println(s)

	// 偏移到第 3 个字段
	up = up0 + unsafe.Offsetof(s.c)
	// 将偏移后的地址转换为通用指针
	p = unsafe.Pointer(up)
	// 将通用指针转换为 byte 型指针
	pb = (*byte)(p)
	// 给转换后的指针赋值
	*pb = 30
	// 结构体内容跟着改变
	fmt.Println(s)

	// 偏移到第 4 个字段
	up = up0 + unsafe.Offsetof(s.d)
	// 将偏移后的地址转换为通用指针
	p = unsafe.Pointer(up)
	// 将通用指针转换为 int64 型指针
	pi := (*int64)(p)
	// 给转换后的指针赋值
	*pi = 40
	// 结构体内容跟着改变
	fmt.Println(s)
}

```

2. 修改私有字段

```
package main

import (
	"fmt"
	"reflect"
	"strings"
	"unsafe"
)

func main() {
	// 创建一个 strings 包中的 Reader 对象
	// 它有三个私有字段：s string、i int64、prevRune int
	sr := strings.NewReader("abcdef")
	// 此时 sr 中的成员是无法修改的
	fmt.Println(sr)
	// readbyte一次 其中的偏移字段i就会+1 从0开始
	b, err := sr.ReadByte()
	fmt.Printf("%c, %v\n", b, err)
	// 但是我们可以通过 unsafe 来进行修改
	// 先将其转换为通用指针
	p := unsafe.Pointer(sr)
	// 获取结构体地址
	up0 := uintptr(p)
	// 确定要修改的字段（这里不能用 unsafe.Offsetof 获取偏移量，因为是私有字段）
	if sf, ok := reflect.TypeOf(*sr).FieldByName("i"); ok {
		// 偏移到指定字段的地址
		up := up0 + sf.Offset
		// 转换为通用指针
		p = unsafe.Pointer(up)
		// 转换为相应类型的指针
		pi := (*int64)(p)
		fmt.Println(*pi)
		// 对指针所指向的内容进行修改
		*pi = 4 // 修改索引 修改索引字段i
	}
	// 看看修改结果
	fmt.Println(sr)
	// 看看读出的是什么
	b, err = sr.ReadByte()
	fmt.Printf("%c, %v\n", b, err)
}
```

3. 类型转换和修改

```
package main

import (
	"fmt"
	"strings"
	"unsafe"
)

// 定义一个和 strings 包中的 Reader 相同的本地结构体
type Reader struct {
	s        string
	i        int64
	prevRune int
}

func main() {
	// 创建一个 strings 包中的 Reader 对象
	sr := strings.NewReader("abcdef")
	// 此时 sr 中的成员是无法修改的
	fmt.Println(sr)
	// 我们可以通过 unsafe 来进行修改
	// 先将其转换为通用指针
	p := unsafe.Pointer(sr)
	// 再转换为本地 Reader 结构体
	pR := (*Reader)(p)
	// 这样就可以自由修改 sr 中的私有成员了
	(*pR).i = 3 // 修改索引
	// 看看修改结果
	fmt.Println(sr)
	// 看看读出的是什么
	b, err := sr.ReadByte()
	fmt.Printf("%c, %v\n", b, err)
}
```

### 参考以及示例参考
1. [https://my.oschina.net/HJCui/blog/1817978](https://my.oschina.net/HJCui/blog/1817978)
2. [https://www.jianshu.com/p/c394436ec9e5?utm_campaign=maleskine&utm_content=note&utm_medium=seo_notes&utm_source=recommendation](https://www.jianshu.com/p/c394436ec9e5?utm_campaign=maleskine&utm_content=note&utm_medium=seo_notes&utm_source=recommendation)
3. [https://tech.meituan.com/2019/02/14/talk-about-java-magic-class-unsafe.html](https://tech.meituan.com/2019/02/14/talk-about-java-magic-class-unsafe.html)
4. [https://juejin.im/post/5a75a4fb5188257a82110544](https://juejin.im/post/5a75a4fb5188257a82110544)
5. [https://leokongwq.github.io/2016/12/31/java-magic-unsafe.html](https://leokongwq.github.io/2016/12/31/java-magic-unsafe.html)