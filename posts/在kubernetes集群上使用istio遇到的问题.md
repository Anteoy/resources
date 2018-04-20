---
date: 2018-04-20 18:33:00
title: 在kubernetes集群上使用istio遇到的问题
categories:
    - kubernetes
tags:
    - kubernetes,harbor,docker,istio
---

#### 前言

按照官方文档安装完成，并检查安装好以后。部署官方示例bookInfo,以及插件grafana,zipkin,promeuthes。本以为后面的使用会十分顺畅，结果不尽人意，发现把测试环境的一个用户中心微服务交给istio管理的之后，居然其他微服务和此为服务之间完全无法相互调用了。后面发现了三个坑。
#### QA

1. istio的微服务如果需要调用外部的http或者grpc等服务，需要使用Egress（意思是出口流量管理的允许），这种情况可参考[https://zhuanlan.zhihu.com/p/35150763](https://zhuanlan.zhihu.com/p/35150763).另外一种解决方法是使用includeIPRanges。如下在部署的时候为istioctl添加参数：

    ```
        - kubectl apply -f <(istioctl kube-inject --includeIPRanges=10.0.0.1/24 -f deploy/$CI_BUILD_REF_SLUG/kube-user.yml)
    ```
    
    其中的**10.0.0.1/24**是我授权访问的ip地址
    
2. 在官方文档说明中，有说明加入sidecar的前提条件，其中说明需要在命名service的暴露端口的时候，使用<protocol>[-<suffix>]，因为我用的之前的yaml编排文件，后面才发现这个也需要改。官方说明如下：

    > Named ports: Service ports must be named. The port names must be of the form <protocol>[-<suffix>] with http, http2, grpc, mongo, or redis as the <protocol> in order to take advantage of Istio’s routing features. For example, name: http2-foo or name: http are valid port names, but name: http2foo is not. If the port name does not begin with a recognized prefix or if the port is unnamed, traffic on the port will be treated as plain TCP traffic (unless the port explicitly uses Protocol: UDP to signify a UDP port).
    
    [https://istio.io/docs/setup/kubernetes/sidecar-injection.html](https://istio.io/docs/setup/kubernetes/sidecar-injection.html)

3. 安装istio的Quick Start文档中，有特别说明如果需要和其他没有istio的服务通信，则必须使用非TLS SIDECAR的安装。当时安装的时候由于没有细看，看了一眼就急匆匆的去安装尝鲜了，结果这个问题后来花了我2,3个小时。原文如下：

    > Install Istio’s core components. Choose one of the two mutually exclusive options below or alternately install with the Helm Chart:
    a) Install Istio without enabling mutual TLS authentication between sidecars. Choose this option for clusters with existing applications, applications where services with an Istio sidecar need to be able to communicate with other non-Istio Kubernetes services, and applications that use liveliness and readiness probes, headless services, or StatefulSets.
    `kubectl apply -f install/kubernetes/istio.yaml`
    Copy
    OR
    b) Install Istio and enable mutual TLS authentication between sidecars.:
    `kubectl apply -f install/kubernetes/istio-auth.yaml`

#### 参考

1. [https://zhuanlan.zhihu.com/p/35150763](https://zhuanlan.zhihu.com/p/35150763)
2. [https://istio.io/docs/setup/kubernetes/sidecar-injection.html](https://istio.io/docs/setup/kubernetes/sidecar-injection.html)

#### 后话
1. 查阅文档的时候，一定要仔细，理解其中的重点，特别是英文文档，中文文档同样也不能走马观花，囫囵吞枣。
2. 切忌心浮气躁，宁静致远。