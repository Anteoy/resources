---
id: 71
date: 2018-05-25 21:03:00
title: 解决kubernetes宿主机top cpu wa io过高引起的cpu资源耗尽问题
categories:
    - kubernetes
tags:
    - kubernetes cpu wa io
---

### 环境
1. cat /etc/redhat-release   

    ```
    CentOS Linux release 7.4.1708 (Core) 
    ```   
2. sudo docker version
    ```
    Client:
     Version:      17.10.0-ce
     API version:  1.33
     Go version:   go1.8.3
     Git commit:   f4ffd25
     Built:        Tue Oct 17 19:04:05 2017
     OS/Arch:      linux/amd64
    
    Server:
     Version:      17.10.0-ce
     API version:  1.33 (minimum version 1.12)
     Go version:   go1.8.3
     Git commit:   f4ffd25
     Built:        Tue Oct 17 19:05:38 2017
     OS/Arch:      linux/amd64
     Experimental: false
    
    ```
3. kubectl version
    ```
    Client Version: version.Info{Major:"1", Minor:"8", GitVersion:"v1.8.0", GitCommit:"6e937839ac04a38cac63e6a7a306c5d035fe7b0a", GitTreeState:"clean", BuildDate:"2017-09-28T22:57:57Z", GoVersion:"go1.8.3", Compiler:"gc", Platform:"linux/amd64"}
    Server Version: version.Info{Major:"1", Minor:"8", GitVersion:"v1.8.1", GitCommit:"f38e43b221d08850172a9a4ea785a86a3ffa3b3a", GitTreeState:"clean", BuildDate:"2017-10-11T23:16:41Z", GoVersion:"go1.8.3", Compiler:"gc", Platform:"linux/amd64"}
    ```
    
### 问题
宿主机cpu占用率非常高,cpu处于资源几近耗尽状态.使用top命令,显示cpu的使用情况是超过80%的cpu占用在wa(IO等待占用CPU的百分比)上,用户空间(us)和内核空间(sy)占用不到20%.id显示的剩余量几近为0.load average也显示较高，如下:   

```
    op - 17:29:08 up 10 days, 19:20,  1 user,  load average: 14.31, 9.34, 9.08
    Tasks: 351 total,   1 running, 350 sleeping,   0 stopped,   0 zombie
    %Cpu(s):  6.9 us,  7.7 sy,  0.3 ni,  2.9 id, 81.7 wa,  0.0 hi,  0.5 si,  0.0 st
    KiB Mem :  8010196 total,   735612 free,  5450964 used,  1823620 buff/cache
    KiB Swap:        0 total,        0 free,        0 used.  1636516 avail Mem 
```

### 排查问题
这个问题在前一段时间也出现过,但最终两次产生的原因不同,上次出现此问题的原因是因为pv挂载的阿里云nfs,刚好宿主机上被调度了es（elasticsearch）,然后es交换nfs数据量太大,导致了连接nfs的网络io太大.而这一次的问题是由于磁盘IO引起的.

1. 使用iotop命令查看机器io情况   
    ```
        Total DISK READ :       9.79 M/s | Total DISK WRITE :      24.66 K/s
        Actual DISK READ:       8.21 M/s | Actual DISK WRITE:       0.00 B/s
          TID  PRIO  USER     DISK READ  DISK WRITE  SWAPIN     IO>    COMMAND                                                      
         5762 be/7 root     1743.49 K/s    0.00 B/s  0.00 % 95.26 % du -s /var/lib/docker/overlay/e~61f203cd85d130b629268078be9c07f4
         5721 be/7 root      750.23 K/s    0.00 B/s  0.00 % 94.64 % du -s /var/lib/docker/overlay/c~dd81ce0684eed62e983301a2bd67e694
           41 be/4 root        0.00 B/s    0.00 B/s  0.00 % 52.87 % [kswapd0]
         5758 be/7 root      200.77 K/s    0.00 B/s  0.00 % 34.72 % du -s /var/lib/docker/overlay/1~803fd9bf781dede9aad4c952530ff38c
         5761 be/7 root      718.53 K/s    0.00 B/s  0.00 % 24.93 % du -s /var/lib/docker/overlay/3~bdb22e8d3cdf465e4a205b1ef72cbd49
         5759 be/7 root      109.19 K/s    0.00 B/s  0.00 % 17.49 % du -s /var/lib/docker/overlay/3~be3fe72d2
    ```   
    
    发现有好几个进程在执行du命令占用了大量的磁盘io.
2. ps -ef | grep 10699 查看进程相关信息
    ```
    root     10699  1675  1 17:44 ?        00:00:00 du -s /var/lib/docker/overlay/e790af60afdf2439c201d6aa2884673ca707e0de2438a6da5009d0717f079de3
    ```
    **查看父进程**  ps -ef | grep 1675   
    ```
    root      1675     1  9 5月14 ?       1-00:38:15 /usr/k8s/bin/kubelet --fail-swap-on=false --cgroup-driver=cgroupfs --address=192.168.1.140 --hostname-override=192.168.1.140 --experimental-bootstrap-kubeconfig=/etc/kubernetes/bootstrap.kubeconfig --kubeconfig=/etc/kubernetes/kubelet.kubeconfig --require-kubeconfig --cert-dir=/etc/kubernetes/ssl --cluster-dns=10.254.0.2 --cluster-domain=cluster.local. --hairpin-mode promiscuous-bridge --allow-privileged=true --serialize-image-pulls=false --logtostderr=true --v=2
    
    ```
    发现是kubelet在调用,kubelet在统计系统磁盘空间信息,由于此前线上环境因为磁盘压力,空间不足的情况出现过大量Pod被驱逐的情形,导致节点上的Pod出现大量被驱逐状态,查看k8s官方说明[https://kubernetes.io/docs/tasks/administer-cluster/out-of-resource/#evicting-end-user-pods](https://kubernetes.io/docs/tasks/administer-cluster/out-of-resource/#evicting-end-user-pods):   
    k8s默认在磁盘小于10%的时候,就会evict pod,导致线上pod不能正常启动了,dashboard上变成红色感叹号.   
3. 查看磁盘空间 df -h
    ```
    /dev/vda1        40G   32G  5.5G   86% /
    devtmpfs        3.9G     0  3.9G    0% /dev
    tmpfs           3.9G     0  3.9G    0% /dev/shm
    tmpfs           3.9G  4.7M  3.9G    1% /run
    tmpfs           3.9G     0  3.9G    0% /sys/fs/cgroup
    tmpfs           783M     0  783M    0% /run/user/1001
    ```
    另外查看github issue,原来其他人也出现过类似问题[https://github.com/kubernetes/kubernetes/issues/23255](https://github.com/kubernetes/kubernetes/issues/23255)   
    [https://github.com/kubernetes/kubernetes/issues/47928](https://github.com/kubernetes/kubernetes/issues/47928)   
    官方说对于此种情况,目前正在优化(kubelet需要搜集系统必要的磁盘空间信息).对于目前此节点出现这个情况,应该是kubelet在磁盘占用较大的时候,会更加频繁地发起du命令计算docker可用的磁盘空间,大量的du命令以及大量的零散文件造成了大量的io,以及cpu的io等待.
    
### 解决方案   
增加磁盘大小,替换机械硬盘为SSD.我们这里把原本40G的云硬盘增加到了100G.后期会考虑用SSD来替换掉.另外个人这里建议,如果条件允许,建议同时加大内存,内存对此问题也有一定影响.

### 附
这里同时顺带记录下之前因为es操作nfs上的数据的时候出现的这个问题所运用到的工具.因为时间有点久远了,这里仅做一些重要的记录,供参考.   

1. 测试磁盘的IO写速度
    ```
    time dd if=/dev/zero of=test.dbf bs=8k count=300000   如果要测试实际速度 还要在末尾加上 oflag=direct测到的才是真实的IO速度
    ```
    
2. 测试磁盘的IO读速度
    ```
    dd if=test.dbf bs=8k count=300000 of=/dev/null
    ```
    
3. iostat命令
    ```
    sudo iostat -x 1 10
    ```
    ```
    avg-cpu:  %user   %nice %system %iowait  %steal   %idle
               7.14    0.26   14.03   67.86    0.00   10.71
    
    Device:         rrqm/s   wrqm/s     r/s     w/s    rkB/s    wkB/s avgrq-sz avgqu-sz   await r_await w_await  svctm  %util
    vda               0.00    44.00 1231.00   14.00 20444.00   232.00    33.21    77.17   61.89   62.57    2.57   0.80  99.90
    vdb               0.00     0.00    0.00    0.00     0.00     0.00     0.00     0.00    0.00    0.00    0.00   0.00   0.00
    
    avg-cpu:  %user   %nice %system %iowait  %steal   %idle
               6.67    0.26    8.72   80.00    0.00    4.36
    
    Device:         rrqm/s   wrqm/s     r/s     w/s    rkB/s    wkB/s avgrq-sz avgqu-sz   await r_await w_await  svctm  %util
    vda               0.00    14.00 1240.00    6.00  5480.00   172.00     9.07    47.39   38.05   38.23    1.00   0.80 100.00
    vdb  
    ```
    对系统的磁盘操作活动进行监视。它的特点是汇报磁盘活动统计情况，同时也会汇报出CPU使用情况。同vmstat一样，iostat也有一个弱点，就是它不能对某个进程进行深入分析，仅对系统的整体情况进行分析。
    
4. vmstat命令(类似于top命令)
    ```
    [zdz@node5 log]$ sudo vmstat 1
    procs -----------memory---------- ---swap-- -----io---- -system-- ------cpu-----
     r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa st
    13 11      0 522460 119404 1896244    0    0   198    70    6    5  9  6 80  5  0
     2 10      0 504968 123668 1905832    0    0  8960    88 10582 17425  6  5  0 89  0
    13  9      0 532004 115180 1888332    0    0  4556     0 10627 17406  7 23  8 61  0
     2 11      0 520568 120080 1897008    0    0  9164     0 10516 18847  7  5  2 87  0
     0 11      0 505616 124320 1906012    0    0  4960     4 9814 14932  6  8  3 83  0
     4 12      0 476292 128952 1924268    0    0  5748    56 11428 18584  5  7  0 87  0
    
    ``` 
    
5. iotop (查看io的类top命令)   
可理解对应iotop与iostat;top与vmstat

6. docker stats --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}"   
监控docker的容器资源占用,如果不想持续的监控容器使用资源的情况，可以通过 --no-stream 选项只输出当前的状态,如:docker stats --no-stream

7. netstat   
查看TCP连接状态：(查看所有tcp连接的状态统计)   
    ```
    netstat -n | awk '/^tcp/ {++S[$NF]} END {for(a in S) print a, S[a]}'
    netstat -n|grep  ^tcp|awk '{print $NF}'|sort -nr|uniq -c
    或者：
    netstat -n | awk '/^tcp/ {++state[$NF]} END {for(key in state) print key,"t",state[key]}'
    返回结果一般如下：
    LAST_ACK 5 （正在等待处理的请求数）
    SYN_RECV 30
    ESTABLISHED 1597 （正常数据传输状态）
    FIN_WAIT1 51
    FIN_WAIT2 504
    TIME_WAIT 1057 （处理完毕，等待超时结束的请求数）
    
    其他参数说明：
    CLOSED：无连接是活动的或正在进行
    LISTEN：服务器在等待进入呼叫
    SYN_RECV：一个连接请求已经到达，等待确认
    SYN_SENT：应用已经开始，打开一个连接
    ESTABLISHED：正常数据传输状态
    FIN_WAIT1：应用说它已经完成
    FIN_WAIT2：另一边已同意释放
    ITMED_WAIT：等待所有分组死掉
    CLOSING：两边同时尝试关闭
    TIME_WAIT：另一边已初始化一个释放
    LAST_ACK：等待所有分组死掉
    ```
    
8. ss命令   
    ```
    ss命令可以用来获取socket统计信息，它可以显示和netstat类似的内容。但ss的优势在于它能够显示更多更详细的有关TCP和连接状态的信息，而且比netstat更快速更高效   
    ss -4 state closing
    ss -u -a
    ss -pl
    ss -s
    ss -t -a
    ```
    
9. iftop命令
```
类似于top的实时流量监控工具
```