---
id: 73
date: 2018-07-21 11:00:00
title: 深信服ssl-vpn在linux ubunt16.04中安装实测笔记
categories:
    - ops
tags:
    - ssl vpn 深信服 easyconnect
---

ps: 原本我是写得比较详细的，写了一大堆，结果突然有道云笔记网页版自动给我刷新了，关键是刷新过后之前写的内容啥都没有。我目前先把安装过程的简略笔记放出来吧，如果有疑问，可以下面评论给我留言，我看到就会回复。

#### 安装坑爹 ssl easyconnect 的公司vpn踩坑记录

1. 目前去我们那个下载页面，发现是老版本，不支持这个easyconnect linux的客户端，于是只能走浏览器的applet了。
2. 现在多数主流浏览器为了安全已经废弃并禁止了applet在浏览器上的运行。被迫选择firefox降级到49。
3. 安装坑爹的applet执行环境来了
4. jdk1.8 也就是用jre1.8 然后找到了bin下的ControlPannel给予域名例外权限，正常运行，但是就是访问不能成功，试了好久还是不行。
5. 被迫尝试jdk1.7中的jre1.7,1.7完全不行
6. 被迫尝试jdk1.6,开启ControlPannel中的debug日志信息。还是不行
7. 被迫尝试jdk1.6的文档中指定版本，还是不行，说找不到类。
8. 调试信息报错异常找不到某个类， 寻找了好久解决方案，最后坑爹的发现，firefox中plugins显示的jdk说的用的1.6 但是jre居然用的还是1.8 操蛋了 
9. 之前给firefox装插件那个浏览器那个路径也是一个坑， 路径在文档中说明是/usr/lib(或者64就是lib64)/mozilla/plugins,但是最后在oracle的官方java文档中发现的应该是在～/.mozilla/plugins下。
10. firefox需允许jre=>url输入about:config=>筛选extensions.blocklist.enabled =>true改为false
11. firefox jre 安装所需依赖=> sudo apt-get install lib32stdc++6=>sudo apt-get install gksu
10. 删除/usr/lib/...下面的plugins还是不行 
11. 最后一气之下就把jdk1.8的目录重命名，再次调试，发现变成了1.7;有眉目了 ，然后依次干掉1.7 和 之前装的另外一个版本的1.6，最后jre在java控制台输出正常了。
12. 另外在bin=> ControlPannel的设置里面看还有没有其他的jre，没有重命名之前，那个都能读取到目前已有的四个jre。
13. 最后只剩下那一个jre，再次尝试，终于成功了。
14. 最后把jdk1.8 和 1.7复原，在./ControlPanel配置中只勾选指定的jre1.6.0_27这个版本的java jre环境，就可以了。

#### 错误后记：

1. Java Plug-in 1.6.0_45 use JRE version 1.8.0_101
2. .ClassNotFoundException: sun/net/www/protocol/http/NTLMAuthenticationCallback
3. ClassNotFoundException: com.sangfor.ssl.bscm.BsApplet.class
4. https://officevpn.int.jumei.com/com/installClient.html
5. https://ftp.mozilla.org/pub/firefox/releases/49.0.2/
6. sudo mv /usr/java/jdk/jdk1.7.0_79 /usr/java/jdk/jdk1.7.0_79.bac
7. ./ControlPanel
8. /usr/java/jre1.6.0_27/bin
9. sudo rm -rf ~/.sangfor/ 
10. ln libnpjp2.so

#### 总结：

1. 无论是官方还是社区的文档，都不一定完全准确或者说完全适合自己的部署环境，遇到这种情况，就只能多参照寻找有价值的社区和官方文档了。
2. 尽量按照文档要求的版本来，能少走不少弯路。不过这次因为jre的版本问题倒是让自己对jre的配置更加熟悉，也算是因祸得福了。

#### 参考：
1. oracle 官方文档 手动安装和注册Linux插件 ~/.mozilla/plugins 谷歌搜索java mozilla plugin
http://www.oracle.com/technetwork/java/javase/manual-plugin-install-linux-136395.html
2. 社区文档参考
    1. https://bbs.sangfor.com.cn/forum.php?mod=viewthread&tid=25913
    2. https://bbs.sangfor.com.cn/forum.php?mod=viewthread&tid=5178
    3. https://bbs.sangfor.com.cn/forum.php?mod=viewthread&tid=15550&extra=&page=2
    4. https://bbs.sangfor.com.cn/plugin.php?id=sangfor_databases:index&mod=viewdatabase&tid=26092
    5. https://bbs.sangfor.com.cn/forum.php?mod=viewthread&tid=39888
