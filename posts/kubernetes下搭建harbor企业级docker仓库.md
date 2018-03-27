---
date: 2018-03-27 22:33:00
title: kubernetes下搭建harbor企业级docker仓库
categories:
    - kubernetes
tags:
    - kubernetes,harbor,docker
---

### 前言
harbor是由vmware开源的企业级docker repository，提供私有仓库，安全认证，权限管理，漏洞扫描及仓库复制等多种功能，因为之前搭建的harbor在线上环境存在各种各样的问题（之前搭建的方式目前发现已被官方宣布弃用[https://github.com/vmware/harbor/blob/master/docs/kubernetes_deployment.md](https://github.com/vmware/harbor/blob/master/docs/kubernetes_deployment.md)，如ui显示不正常，权限认证不正常），于是近期抽空用官方推荐的helm方式对harbor进行重新部署，并替换掉线上harbor

### 准备
1. Kubernetes集群1.8+
2. Kubernetes Ingress Controller已启用(这里我们选用的traefik-ingress)
3. kubectl 客户端 1.8+
4. 可选的持久化功能需要准备PV或者SC（我们这里使用nfs创建的PV和PVC，如果有条件使用SC的会更加方便）

### 部署过程
1. 首先按照[官方教程](https://github.com/kubernetes/helm#install)安装[Helm](https://github.com/kubernetes/helm#install)，然后初始化Helm。

    `注意`： 初始化需要使用下面命令使用canary镜像，否则无法正常安装，会报错helm部署文件的格式不正确，目前这是一个已知issue:[https://github.com/vmware/harbor/issues/4484](https://github.com/vmware/harbor/issues/4484)
    
    ```
    helm init --canary-image
    ```
    
    如果你和我一样，在这之前已经用官方教程安装好了helm，则可使用下面命令更新helm server:
    
    ```
    helm init --canary-image --upgrade
    ```
    
2. 下载helm部署代码并进入harbor helm目录。

    ```
    git clone https://github.com/vmware/harbor
    cd harbor/contrib/helm/harbor
    ```
    
    推荐使用这个连接下载指定的文件夹，否则在网络不佳的情况下拉取全部代码会比较耗时:
    
    ```
    https://minhaskamal.github.io/DownGit/#/home
    ```

3. 更新helm dependency

    harbor的helm部署依赖了postgresql的helm，在官方的安装文档没有明确说明，因为我也是第一次使用，直接按照官方文档说明安装，就会缺失postgresql的部署，导致整个服务无法启动
    
    ```
    helm dependency update
    ```
    
4. 安装harbor

    这里官方提供了两种方式，Insecure和Secure，我这里选用的是Secure安全的部署方式，让harbor自己生成CA和SSL，简单方便。执行如下命令安装harbor:
    
    ```
    helm install . --debug --name hub --set externalDomain=harbor.my.domain
    ```
    
    externalDomain为外部能访问到harbor的域名，到目前为止，你可以在本地/etc/hosts中添加域名解析，从本地访问进行测试，待测试完成后再加入traefik-ingress中，当然你也可以直接在traefik-ingress中添加域名解析。
   
   
5. 添加traefik-ingress的域名解析
    ```
        apiVersion: extensions/v1beta1
        kind: Ingress
        metadata:
          name: traefik-default-ingress
          namespace: default
          annotations:
            kubernetes.io/ingress.class: "traefik"
        spec:
          rules:
          - host: harbor.my.domain
            http:
              paths:
              - path: /
                backend:
                  serviceName: my-release-harbor-ui
                  servicePort: 80
    ```

### helm harbor自定义配置   
注意： 我这里把所有自定义配置放到后面的附录中，供大家参考,同时可以点击[https://github.com/Anteoy/harbor-helm/commit/226b296d130b4f956f8463eecf2aa473bc1e844c](https://github.com/Anteoy/harbor-helm/commit/226b296d130b4f956f8463eecf2aa473bc1e844c),查看我上传到github的自定义配置，从github阅读更清晰。

1. 重要：在生产环境中需要持久化数据存储，否则pod重启或重建会造成数据丢失。如果有创建好的storageClass可以直接在values.yaml配置，如果没有或暂时不能使用SC的，比如我这里只有nfs，则需要像我一样多修改一些配置。另外,nfs其实在社区也有storageClass的驱动库，不过我看了下使用起来较为繁琐，于是这里仍然修改为使用nfs。
2. 修改templates默认的namespace，注意需要修改依赖的chart文件夹下的postgresql-0.9-1.tgz压缩文件中的部署yaml模板，否则harbor的ui,register,mysql和postgresql不在一个namespace下，不能正常安装
3. 注意修改postgresql的持久化数据卷，可参考[https://github.com/kubernetes/charts/tree/master/stable/postgresql](https://github.com/kubernetes/charts/tree/master/stable/postgresql)
 
### 附录

```
 templates/adminserver/adminserver-cm.yaml
@@ -1,6 +1,7 @@
 apiVersion: v1
 kind: ConfigMap
 metadata:
+  namespace: class100-ops
   name: "{{ template "harbor.fullname" . }}-adminserver"
   labels:
 {{ include "harbor.labels" . | indent 4 }}
  
1  templates/adminserver/adminserver-secrets.yaml
@@ -2,6 +2,7 @@ apiVersion: v1
 kind: Secret
 metadata:
   name: "{{ template "harbor.fullname" . }}-adminserver"
+  namespace: class100-ops
   labels:
 {{ include "harbor.labels" . | indent 4 }}
     component: adminserver
  
5  templates/adminserver/adminserver-ss.yaml
@@ -2,6 +2,7 @@ apiVersion: apps/v1beta2
 kind: StatefulSet
 metadata:
   name: "{{ template "harbor.fullname" . }}-adminserver"
+  namespace: class100-ops
   labels:
 {{ include "harbor.labels" . | indent 4 }}
     component: adminserver
@@ -42,13 +43,15 @@ spec:
         volumeMounts:
         - name: adminserver-config
           mountPath: /etc/adminserver/config
+          subPath: harbor-v1/adminserver/
         - name: adminserver-key
           mountPath: /etc/adminserver/key
           subPath: key
       volumes:
       {{- if not .Values.persistence.enabled }}
       - name: adminserver-config
-        emptyDir: {}
+        persistentVolumeClaim:
+          claimName: harbor-pvc
       {{- end }}
       - name: adminserver-key
         secret:
  
1  templates/adminserver/adminserver-svc.yaml
@@ -2,6 +2,7 @@ apiVersion: v1
 kind: Service
 metadata:
   name: "{{ template "harbor.fullname" . }}-adminserver"
+  namespace: class100-ops
 spec:
   ports:
     - port: 80
  
1  templates/clair/clair-cm.yaml
@@ -3,6 +3,7 @@ apiVersion: v1
 kind: ConfigMap
 metadata:
   name: {{ template "harbor.fullname" . }}-clair
+  namespace: class100-ops
   labels:
 {{ include "harbor.labels" . | indent 4 }}
     component: clair
  
1  templates/clair/clair-dpl.yaml
@@ -3,6 +3,7 @@ apiVersion: extensions/v1beta1
 kind: Deployment
 metadata:
   name: {{ template "harbor.fullname" . }}-clair
+  namespace: class100-ops
   labels:
 {{ include "harbor.labels" . | indent 4 }}
     component: clair
  
1  templates/clair/clair-svc.yaml
@@ -6,6 +6,7 @@ apiVersion: v1
 kind: Service
 metadata:
   name: clair
+  namespace: class100-ops
   labels:
 {{ include "harbor.labels" . | indent 4 }}
 spec:
  
1  templates/ingress/ingress.yaml
@@ -2,6 +2,7 @@ apiVersion: extensions/v1beta1
 kind: Ingress
 metadata:
   name: "{{ template "harbor.fullname" . }}-ingress"
+  namespace: class100-ops
   labels:
 {{ include "harbor.labels" . | indent 4 }}
   annotations:
  
1  templates/ingress/secret.yaml
@@ -5,6 +5,7 @@ apiVersion: v1
 kind: Secret
 metadata:
   name: "{{ template "harbor.fullname" . }}-ingress"
+  namespace: class100-ops
   labels:
 {{ include "harbor.labels" . | indent 4 }}
 type: kubernetes.io/tls
  
1  templates/jobservice/jobservice-cm.yaml
@@ -2,6 +2,7 @@ apiVersion: v1
 kind: ConfigMap
 metadata:
   name: "{{ template "harbor.fullname" . }}-jobservice"
+  namespace: class100-ops
   labels:
 {{ include "harbor.labels" . | indent 4 }}
 data:
  
1  templates/jobservice/jobservice-dpl.yaml
@@ -2,6 +2,7 @@ apiVersion: extensions/v1beta1
 kind: Deployment
 metadata:
   name: "{{ template "harbor.fullname" . }}-jobservice"
+  namespace: class100-ops
   labels:
 {{ include "harbor.labels" . | indent 4 }}
     component: jobservice
  
1  templates/jobservice/jobservice-secrets.yaml
@@ -2,6 +2,7 @@ apiVersion: v1
 kind: Secret
 metadata:
   name: "{{ template "harbor.fullname" . }}-jobservice"
+  namespace: class100-ops
   labels:
 {{ include "harbor.labels" . | indent 4 }}
 type: Opaque
  
1  templates/jobservice/jobservice-svc.yaml
@@ -2,6 +2,7 @@ apiVersion: v1
 kind: Service
 metadata:
   name: "{{ template "harbor.fullname" . }}-jobservice"
+  namespace: class100-ops
   labels:
 {{ include "harbor.labels" . | indent 4 }}
 spec:
  
1  templates/mysql/mysql-secret.yaml
@@ -2,6 +2,7 @@ apiVersion: v1
 kind: Secret
 metadata:
   name: "{{ template "harbor.fullname" . }}-mysql"
+  namespace: class100-ops
   labels:
 {{ include "harbor.labels" . | indent 4 }}
 type: Opaque
  
7  templates/mysql/mysql-ss.yaml
@@ -2,6 +2,7 @@ apiVersion: apps/v1beta2
 kind: StatefulSet
 metadata:
   name: "{{ template "harbor.fullname" . }}-mysql"
+  namespace: class100-ops
   labels:
 {{ include "harbor.labels" . | indent 4 }}
     component: mysql
@@ -33,10 +34,12 @@ spec:
         volumeMounts:
         - name: mysql-data
           mountPath: /var/lib/mysql
+          subPath: harbor-v1/mysql-data/
       {{- if not .Values.persistence.enabled }}
       volumes:
-      - name: "mysql-data"
-        emptyDir: {}
+      - name: mysql-data
+        persistentVolumeClaim:
+          claimName: harbor-pvc
       {{- end -}}
   {{- if .Values.persistence.enabled }}
   volumeClaimTemplates:
  
1  templates/mysql/mysql-svc.yaml
@@ -2,6 +2,7 @@ apiVersion: v1
 kind: Service
 metadata:
   name: "{{ template "harbor.fullname" . }}-mysql"
+  namespace: class100-ops
   labels:
 {{ include "harbor.labels" . | indent 4 }}
 spec:
  
1  templates/registry/registry-cm.yaml
@@ -2,6 +2,7 @@ apiVersion: v1
 kind: ConfigMap
 metadata:
   name: "{{ template "harbor.fullname" . }}-registry"
+  namespace: class100-ops
   labels:
 {{ include "harbor.labels" . | indent 4 }}
 data:
  
1  templates/registry/registry-secret.yaml
@@ -2,6 +2,7 @@ apiVersion: v1
 kind: Secret
 metadata:
   name: "{{ template "harbor.fullname" . }}-registry"
+  namespace: class100-ops
   labels:
 {{ include "harbor.labels" . | indent 4 }}
 type: Opaque
  
5  templates/registry/registry-ss.yaml
@@ -2,6 +2,7 @@ apiVersion: apps/v1beta2
 kind: StatefulSet
 metadata:
   name: "{{ template "harbor.fullname" . }}-registry"
+  namespace: class100-ops
   labels:
 {{ include "harbor.labels" . | indent 4 }}
     component: registry
@@ -37,6 +38,7 @@ spec:
         volumeMounts:
         - name: registry-data
           mountPath: /var/lib/registry
+          subPath: harbor-v1/registry-data/
         - name: registry-root-certificate
           mountPath: /etc/registry/root.crt
           subPath: root.crt
@@ -47,7 +49,8 @@ spec:
 {{- if not .Values.registry.objectStorage }}
 {{- if not .Values.persistence.enabled }}
       - name: registry-data
-        emptyDir: {}
+        persistentVolumeClaim:
+          claimName: harbor-pvc
 {{- end }}
 {{- end }}
       - name: registry-root-certificate
  
1  templates/registry/registry-svc.yaml
@@ -2,6 +2,7 @@ apiVersion: v1
 kind: Service
 metadata:
   name: "{{ template "harbor.fullname" . }}-registry"
+  namespace: class100-ops
   labels:
 {{ include "harbor.labels" . | indent 4 }}
 spec:
  
1  templates/ui/ui-cm.yaml
@@ -2,6 +2,7 @@ apiVersion: v1
 kind: ConfigMap
 metadata:
   name: "{{ template "harbor.fullname" . }}-ui"
+  namespace: class100-ops
   labels:
 {{ include "harbor.labels" . | indent 4 }}
 data:
  
3  templates/ui/ui-dpl.yaml
@@ -2,6 +2,7 @@ apiVersion: extensions/v1beta1
 kind: Deployment
 metadata:
   name: "{{ template "harbor.fullname" . }}-ui"
+  namespace: class100-ops
   labels:
 {{ include "harbor.labels" . | indent 4 }}
     component: ui
@@ -54,8 +55,10 @@ spec:
           subPath: private_key.pem
         - name: ca-download
           mountPath: /etc/ui/ca
+          subPath: harbor-v1/ui-ca/
         - name: psc
           mountPath: /etc/ui/token
+          subPath: harbor-v1/ui-psc/
       volumes:
       - name: ui-config
         configMap:
  
1  templates/ui/ui-secrets.yaml
@@ -2,6 +2,7 @@ apiVersion: v1
 kind: Secret
 metadata:
   name: "{{ template "harbor.fullname" . }}-ui"
+  namespace: class100-ops
   labels:
 {{ include "harbor.labels" . | indent 4 }}
 type: Opaque
  
1  templates/ui/ui-svc.yaml
@@ -2,6 +2,7 @@ apiVersion: v1
 kind: Service
 metadata:
   name: "{{ template "harbor.fullname" . }}-ui"
+  namespace: class100-ops
   labels:
 {{ include "harbor.labels" . | indent 4 }}
 spec:
  
3  values.yaml
@@ -287,4 +287,5 @@ postgresql:
   postgresPassword: not-a-secure-password
   postgresDatabase: clair
   persistence:
-    enabled: false
+    enabled: true
+    existingClaim: harbor-pvc 
```

### 参考
1. [https://github.com/vmware/harbor/issues/4484](https://github.com/vmware/harbor/issues/4484)
2. [https://github.com/vmware/harbor/tree/master/contrib/helm/harbor](https://github.com/vmware/harbor/tree/master/contrib/helm/harbor)
3. [https://github.com/vmware/harbor/issues/4481](https://github.com/vmware/harbor/issues/4481)
4. [https://kubernetes.io/docs/concepts/storage/storage-classes/#introduction](https://kubernetes.io/docs/concepts/storage/storage-classes/#introduction)