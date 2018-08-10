
---
id: 74
date: 2018-08-10 18:42:00
title: 自建对象存储服务minio在使用nginx进行反向代理时出现对象无法正常共享的解决办法
categories:
    - ops
tags:
    - minio nginx
---

### 什么是minio
> Minio是在Apache License v2.0下发布的对象存储服务器。它与Amazon S3云存储服务兼容。它最适合存储非结构化数据，如照片，视频，日志文件，备份和容器/VM镜像等。对象的大小可以从几KB到最大5TB。

### docker 安装示例
```
docker run -p 9000:9000 --name minio1   -e "MINIO_ACCESS_KEY=自己的access_key,相当于用户名"   -e "MINIO_SECRET_KEY=自己的secret_key,相当于密码"   -v /mnt/minio-data-v1:/data   -v /mnt/minio-v1:/root/.minio  -d  minio/minio:RELEASE.2018-07-31T02-11-47Z server /data
```

### 使用nginx进行反向代理
因为服务器有其他服务,并且使用的nginx作为反向代理,初始配置如下:   
在/etc/nginx/conf.d下新建文件minio.conf
```
server {
    listen 80;
    gzip on;
    server_name oss.allocmem.com;
    location / {
      proxy_pass http://127.0.0.1:9000;
    }
}

```
nginx -s relaod让nginx重新加载

### 出现问题
在使用上面配置的用户名和密码进入主页后,上传了自己的文件,当点击生成共享连接的时候,如下图:

![](http://oss.allocmem.com/blog/1.jpg)

访问这个共享连接会报错SignatureDoesNotMatch:

![](http://oss.allocmem.com/blog/2.jpg)

### 原因及解决方案
错误提示SignatureDoesNotMatch签名不正确,后来发现和nginx反向代理在做转发的时候所携带的header有关系.minio在校验signature是否有效的时候,必须从http header里面获取host,而我们这里没有对header作必要的处理.如果源请求未携带这个头,则minio处无法获取请求头中的host,目前我这里测试看请求有携带Host,这里的机制问题出在nginx,nginx没有把这个host转发过去,而用ip的时候Host为 ip:port,这种情况是正常的,这应该和nginx的默认配置proxy_set_header Host       $http_host有关系
> 如果不想改变请求头“Host”的值，可以这样来设置：
> proxy_set_header Host       $http_host;
但是，如果客户端请求头中没有携带这个头部，那么传递到后端服务器的请求也不含这个头部。 这种情况下，更好的方式是使用$host变量——它的值在请求包含“Host”请求头时为“Host”字段的值，在请求未携带“Host”请求头时为虚拟主机的主域名：

我们这里的minio.conf需要添加下面代码
```
proxy_set_header Host  $host;
```
$host代表的是当前虚拟主机的host,即上面配置的oss.allcmem.com.完整示例如下:
```
server {
    listen 80;
    gzip on;
    server_name oss.allocmem.com;
    location / {
      proxy_pass http://127.0.0.1:9000;
      proxy_set_header   Host    $host;
    }

}

```

### 参考
1. [https://docs.minio.io/](https://docs.minio.io/)
2. [http://liuluo129.iteye.com/blog/1943311](http://liuluo129.iteye.com/blog/1943311)