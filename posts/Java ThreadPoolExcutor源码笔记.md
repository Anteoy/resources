---
id: 102
date: 2019-04-11 14:03:20
title: Java ThreadPoolExcutor源码笔记
categories:
    - java
tags: 
    - java,string,源码
---

### 概要速记
接口Excutor->接口ExutorService->抽象类AbstractExcutorService->类ThreadPoolExcutor

线程达到上限策略corePollSize->blockQueue->maxPollSize->handle

blockQueue参数如果使用LinkedBlockQueue则会使maxPollSize参数无效 此为无界队列

一般使用有界队列ArrayBlockQueue

有个参数设置核心线程外的keepalive time，超时线程会被销毁 

### ThreadPoolExecutor分析
#### 部分字段分析

1. private final AtomicInteger ctl = new AtomicInteger(ctlOf(RUNNING, 0));   
    使用Integer.SIZE - 3以及-1（-1的二进制表示，在计算机器的世界用补码表示的，除符号位按位取反再加1:11111111111111111111111111111111）进行位移得到的RUNNING的二进制为11100000000000000000000000000000    
    ctlOf是return RUNNING|0 所以ctl的初始值也为11100000000000000000000000000000    
    AtomicInteger是Java中使用CAS机制实现的保证原子操作的Integer类  
    查看类注释    

    ```
    * The main pool control state, ctl, is an atomic integer packing
    * two conceptual fields
    *   workerCount, indicating the effective number of threads
    *   runState,    indicating whether running, shutting down etc
    * In order to pack them into one int, we limit workerCount to
    * (2^29)-1 (about 500 million) threads rather than (2^31)-1 (2
    * billion) otherwise representable. 
    ```    

    使用4字节32位的ctl字段，包含两部分的信息: 线程池的运行状态 (runState) 和线程池内有效线程的数量 (workerCount)，这里可以看到，使用了Integer类型来保存，高3位保存runState，低29位保存workerCount。

    有如下状态以及状态转换
    
    ```
     * RUNNING -> SHUTDOWN
     *    On invocation of shutdown(), perhaps implicitly in finalize()
     * (RUNNING or SHUTDOWN) -> STOP
     *    On invocation of shutdownNow()
     * SHUTDOWN -> TIDYING
     *    When both queue and pool are empty
     * STOP -> TIDYING
     *    When pool is empty
     * TIDYING -> TERMINATED
     *    When the terminated() hook method has completed
    ```

2. private static final int CAPACITY   = (1 << COUNT_BITS) - 1;CAPACITY就是1左移29位减1（29个1），这个常量表示workerCount的上限值，(2^29)-1=536870911。

3. 下面是二进制高位存储的线程池状态的常量代码

    ```
    // runState is stored in the high-order bits
    private static final int RUNNING    = -1 << COUNT_BITS;
    private static final int SHUTDOWN   =  0 << COUNT_BITS;
    private static final int STOP       =  1 << COUNT_BITS;
    private static final int TIDYING    =  2 << COUNT_BITS;
    private static final int TERMINATED =  3 << COUNT_BITS;
    ```

4. private final HashSet<Worker> workers = new HashSet<Worker>();
    Worker类是ThreadPoolExecutor的一个内部类 这个类实现了Runnable接口 是线程池中线程的载体 新建线程则为添加一个Worker。
    同时Worker类继承了AbstractQueuedSynchronizer这个抽象类
    此抽象类基于双向链表实现的双端队列来实现锁的灵活控制
    首先需要了解可重入锁和不可重入锁 具体可以点击[这里](https://blog.csdn.net/rickiyeat/article/details/78314451)   
    实现此抽象类的原因 主要是借此实现一个不可重入锁 来避免线程在执行任务的时候 能够重入进去类似setCorePoolSize()方法从而中断了正在执行任务的线程
    同时据此还能判断此线程是否处于空闲状态


5. 阻塞线程队列字段
private final BlockingQueue<Runnable> workQueue;

#### 部分方法分析
1. 构造方法

    ```
    public ThreadPoolExecutor(int corePoolSize,
                              int maximumPoolSize,
                              long keepAliveTime,
                              TimeUnit unit,
                              BlockingQueue<Runnable> workQueue,
                              ThreadFactory threadFactory,
                              RejectedExecutionHandler handler) {
        if (corePoolSize < 0 ||
            maximumPoolSize <= 0 ||
            maximumPoolSize < corePoolSize ||
            keepAliveTime < 0)
            throw new IllegalArgumentException();
        if (workQueue == null || threadFactory == null || handler == null)
            throw new NullPointerException();
        this.corePoolSize = corePoolSize;
        this.maximumPoolSize = maximumPoolSize;
        this.workQueue = workQueue;
        this.keepAliveTime = unit.toNanos(keepAliveTime);
        this.threadFactory = threadFactory;
        this.handler = handler;
    }
    ```

    corePoolSize是初始时即会创建的固定的线程数量  
    maximumPoolSize最大线程数量 如果线程池中的线程数量大于等于corePoolSize且小于maximumPoolSize，则只有当workQueue满时才创建新的线程去处理任务  
    keepAliveTime保持超出核心线程的临时增加的线程在空闲状态下，超过此参数设置的空闲时间，那么这部分临时增加的线程会被销毁  
    unit keepAliveTime的时间单位TimeUnit  
    workQueue 使用的阻塞队列 在核心线程已满载的情况下 有新的任务到达线程池则会放入线程队列中 通常用ArrayBlockQueue，有大小限制的队列。LinkedArrayQueue则是无界无数量限制的队列，用这个如果任务太多，有可能会把内存资源耗尽  
    threadFactory 创建线程的工厂类 一般使用默认的Executors.defaultThreadFactory()  
    handler 当the thread bounds and queue capacities are reached，也就是达到maximumPoolSize最大线程数量，并且workQueue也被塞满了，这个时候就依靠传入的handler对象 自定义决定如何处理 有默认实现private static final RejectedExecutionHandler defaultHandler = new AbortPolicy();直接抛出RejectedExecutionException  

2. public <T> Future<T> submit(Callable<T> task)  
    在ThreadPoolExecutor这个类本身的代码文件中，是没有这个submit的，但是因为继承了抽象类AbstractExecutorService，而submit方法在AbstractExecutroService里面就有一个默认实现，ThreadPoolExecutor自然就继承了下来。   
    这个方法主要是用于实现callable接口的有返回值的线程执行   

    ```
        RunnableFuture<T> ftask = newTaskFor(task);
        execute(ftask);
        return ftask;
    ```

    可见新建一个task后，最终仍调用的ThreadPoolExecutor类的execute方法(通过DEBUG也可以看到这个调用过程)  

3. public void execute(Runnable command)
    此方法处理上面提到的线程新建的机制，在小于核心池并且线程池处于running状态，则addWorker，如果核心池已满但可以加入queue，则在queue中addWorker,由于在并发执行条件下会变，所以类似于单例懒汉模式下的双检一样，这里也存在一个双重检查

    ```
    if (workerCountOf(c) < corePoolSize) {
                if (addWorker(command, true))
                    return;
                c = ctl.get();
            }
            if (isRunning(c) && workQueue.offer(command)) {
                int recheck = ctl.get();
                if (! isRunning(recheck) && remove(command))
                    reject(command);
                else if (workerCountOf(recheck) == 0)
                    addWorker(null, false);
            }
    ```

    其他不能处理的情况则调用reject(command),reject内部调用handler  

4. private boolean addWorker(Runnable firstTask, boolean core)   
    core参数为true表示在新增线程时会判断当前活动线程数是否少于corePoolSize，false表示新增线程前需要判断当前活动线程数是否少于maximumPoolSize

    此外，还有控制线程池生命周期的相关方法，如shutdownNow方法（立即中断所有线程），interruptIdleWorkers方法，shutdown方法（等待忙碌线程继续执行，中断空闲线程）等，具体这里就不作详细介绍了，大家可以自己亲自动手去看下

#### Ref
1. [https://www.jianshu.com/p/d2729853c4da](https://www.jianshu.com/p/d2729853c4da)c4da)