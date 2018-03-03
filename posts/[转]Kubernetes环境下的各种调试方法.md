---
id: 64
date: 2018-03-03 10:33:00
title: [转]Kubernetes环境下的各种调试方法
categories:
    - 转载
tags:
    - Kubernetes 调试
---
作者:Jack47

转载请保留作者和原文出处

欢迎关注我的微信公众账号程序员杰克，两边的文章会同步，也可以添加我的RSS订阅源。

#### 本文介绍在Kubernetes环境下的调试方法
1. 启动单个容器 不使用Pod或Replication Controller，启动单个容器:
	```
	$ kubectl run webserver --image=nginx
	```
2. 想更改镜像，又不想升级版本？
    每次修改之后，需要更新镜像的版本也好烦人啊。每次构建出新的镜像，Push到Docker Registry时，可以使用一个固定的版本，然后让Kubernetes在启动某个镜像时，无论本地是否有镜像，都去Docker Registry拉取镜像就好了。
    ImagePullPolicy从默认的 IfNotPresent,改为 Always。

3. 想直接修改容器里的程序，又不想更新镜像？

    什么，还能这样做？在容器内部修改，比如修改了脚本，或者直接替换二进制程序，然后使用docker restart container-id。我尝试过此时使用docker commit提交修改,但是下次启动时，Kubernets就会报错。应该是有完整性校验的原因。
    
4. Pod重启了，如何看重启之前的日志？
    下面的命令只能看到当前Pod的日志：
    ```
    $ kubectl logs zookeeper-1
    ```
    通过 --previous参数可以看之前Pod的日志
    ```
    $ kubectl logs zookeeper-1 --previous
    ```
5. 查看Pod生命周期的事件
    通过如下命令，看命令末尾 events 一节，查看kubelet给APIServer发送的Pod生命周期里发生的事件
    ```
    $ kubectl describe pod podname
    ```
6. 没有看到任何事件，但是Pod重启了？
依然通过describe命令，Containers.[*].Last State部分：
	```
	$ kubectl describe pod podname
	Name:       kafka-1 
	...
	
	Containers:
	  kafka:
	    ...
	    State:      Running
	       Started:     Sat, 08 Apr 2017 02:29:04 +0000
	    Last State:     Terminated
	       Reason:      OOMKilled
	      Exit Code:    0
	       Started:     Fri, 07 Apr 2017 11:06:56 +0000
	      Finished:     Sat, 08 Apr 2017 02:29:04 +0000
	    Ready:      True
	   Restart Count:   1
	...
	```
	可以看到 Kafka-1 这个Container因为内存消耗太多，达到内存的上限(Memory Resource Limit)而被干掉了。如果看到 Reason: Completed,说明是容器内部pid为1的程序主动退出的。

7. 查看资源(CPU/Memory)使用情况
    
    资源使用最多的节点
    ```
    $ kubectl top nodes
    ```
    资源使用最多的Pod
    ```
    $ kubectl top pods
    ```
    查看节点的资源使用情况
    ```
    $ kubectl describe nodes | grep -A 2 -e "^\\s*CPU Requests"
    ```
8. 如何摘下某个Pod进行Debug
    使用label机制，对Pod进行标记。在Service定义中，我们添加 status: serving字段。当需要摘下某个Pod做Debug，而又不影响整个服务，可以：
    ```
    $ kubectl get pods --selector="status=serving"
    $ kubectl label pods webserver-rc-lxag2 --overwrite status=debuging
    ```
    此时kubelet就会把这个Pod从Service的后端列表中删掉。等到Debug完，想恢复？再改回去就好了：
    ```
    $ kubectl label pods webserver-rc-lxag2 --overwrite status=serving
    ```
### References:

* [10 most common reasons kuberntes deployments fail](https://kukulinski.com/10-most-common-reasons-kubernetes-deployments-fail-part-2/)
* [Kubernetes Community Resources](http://k8s.info/recipes.html)
)
