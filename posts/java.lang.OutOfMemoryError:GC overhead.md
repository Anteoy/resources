---
id: 76
date: 2018-08-20 15:47:00
title: java.lang.OutOfMemoryError:GC overhead limit exceeded
categories:
    - java
tags:
    - java oom "GC overhead limit exceeded"
---

### 前言

在我们写的java service里,需要加载一个比较大的算法模型pmml文件.在此模型文件由500M+变为1G+的时候,在测试环境中出现了此问题

### 异常由来

> GC overhead limt exceed检查是Hotspot VM 1.6定义的一个策略，通过统计GC时间来预测是否要OOM了，提前抛出异常，防止OOM发生。Sun 官方对此的定义是：“并行/并发回收器在GC回收时间过长时会抛出OutOfMemroyError。过长的定义是，超过98%的时间用来做GC并且回收了不到2%的堆内存。用来避免内存过小造成应用不能正常工作。

代码中使用静态对象的方式用来在多线程中共享此文件模型,由于加载文件过大,并且长时间的GC回收了不到2%的内存,于是抛出了这个异常

这个异常的作用:
> 在应用oom之前,数据保存或者保存现场（Heap Dump）

但是在加在大文件的时候,恰好会抛出此异常

### 解决方案

加大堆内存 并且关闭此特性

在启动时候,加入参数
```
-XX:-UseGCOverheadLimit -Xmx4096m
```

### 附

> 更新 JDK 1.8 HotSpot的情况如下：
你可以在Linux下执行以下命令查看Xms和Xmx的默认值
java -XX:+PrintFlagsFinal -version | grep HeapSize

> 另外这是Java8的文档中关于Default Heap Size的描述：点击这里

> hotspot虚拟机的默认堆大小如果未指定，他们是根据服务器物理内存计算而来的

> client模式下，JVM初始和最大堆大小为：
在物理内存达到192MB之前，JVM最大堆大小为物理内存的一半，否则，在物理内存大于192MB，在到达1GB之前，JVM最大堆大小为物理内存的1/4，大于1GB的物理内存也按1GB计算，举个例子，如果你的电脑内存是128MB，那么最大堆大小就是64MB，如果你的物理内存大于或等于1GB，那么最大堆大小为256MB。
Java初始堆大小是物理内存的1/64，但最小是8MB。

> server模式下：
与client模式类似，区别就是默认值可以更大，比如在32位JVM下，如果物理内存在4G或更高，最大堆大小可以提升至1GB，，如果是在64位JVM下，如果物理内存在128GB或更高，最大堆大小可以提升至32GB。

另外 jps -vml 可以显示当前所有java进程以及其启动参数

### 引用及参考
1. [https://segmentfault.com/q/1010000007235579](https://segmentfault.com/q/1010000007235579)
2. [https://www.cnblogs.com/hucn/p/3572384.html](https://www.cnblogs.com/hucn/p/3572384.html)