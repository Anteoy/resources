---
id: 74
date: 2016-11-30 10:35:34
title: [转]linux中service与chkconfig的替代者systemctl
categories:
    - 转载
tags:
    - linux service chkconfig systemctl
---
原文地址：
[http://www.111cn.net/sys/linux/65797.htm](http://www.111cn.net/sys/linux/65797.htm)
linux中有很多命令已经存在了N多年，渐渐一些已被一些新命令所代替，不过由于习惯的原因，很多时候我们并不能一下子适应过来 ，例如ifconfig之于ip命令。该命令是用来替代service和chkconfig两个命令的 --- 尽管个人感觉还是后者好用。
为了顺应时间的发展，这里总结下。在目前很多linux的新发行版本里，系统对于daemon的启动管理方法不再采用SystemV形式，而是使用了sytemd的架构来管理daemon的启动。
一、runlevel 到 target的改变
在systemd的管理体系里面，以前的运行级别（runlevel）的概念被新的运行目标（target）所取代。tartget的命名类似于multi-user.target等这种形式，比如原来的运行级别3（runlevel3）就对应新的多用户目标（multi-user.target），run level 5就相当于graphical.target。
由于不再使用runlevle概念，所以/etc/inittab也不再被系统使用 --- 无怪乎在新版本ubuntu上找不到inittab文件了。
而在systemd的管理体系里面，默认的target（相当于以前的默认运行级别）是通过软链来实现。如：
ln -s /lib/systemd/system/runlevel3.target /etc/systemd/system/default.target
在/lib/systemd/system/ 下面定义runlevelX.target文件目的主要是为了能够兼容以前的运行级别level的管理方法。 事实上/lib/systemd/system/runlevel3.target，同样是被软连接到multi-user.target。
注：opensuse下是在/usr/lib/systemd/system/目录下。
二、单元控制（unit）
在systemd管理体系里，称呼需要管理的daemon为单元（unit）。对于单元（unit）的管理是通过命令systemctl来进行控制的。例如显示当前的处于运行状态的unit(即daemon)，如：
systemctl
systemctl --all
systemctl list-units --type=sokect
systemctl list-units --type=service
注:type后面可以接的类型可以通过help查看
361way:~ # systemctl -t help
Available unit types:
service
socket
target
device
mount
automount
snapshot
timer
swap
path
slice
scope
三、systemctl用法及示例
chkconfig、service命令与systemctl命令的区别见下表：
word-spacing: 0px; padding-top: 0px; -webkit-text-size-adjust: auto; -webkit-text-stroke-width: 0px" border="2" cellspacing="2" cellpadding="2">
		
任务 | 旧指令 | 新指令
-----|-------|----------
使某服务自动启动 | chkconfig --level 3 httpd on  | systemctl enable httpd.service
使某服务不自动启动 | chkconfig --level 3 httpd off  | systemctl disable httpd.service
检查服务状态 | service httpd status  | systemctl status httpd.service （服务详细信息）systemctl is-active httpd.service （仅显示是否 Active)
加入自定义服务|chkconfig --add  test|systemctl   load test.service
删除服务|chkconfig --del  xxx|停掉应用，删除相应的配置文件
显示所有已启动的服务|chkconfig --list|systemctl list-units --type=service
启动某服务|service httpd start|systemctl start httpd.service
停止某服务|service httpd stop|systemctl stop httpd.service
重启某服务|service httpd restart|systemctl restart httpd.service
注：systemctl后的服务名可以到/usr/lib/systemd/system目录查看（opensuse下），其他发行版是位于/lib/systemd/system/ 下。
//opensuse下
361way:~ # systemctl status network.service
network.service - LSB: Configure network interfaces and set up routing
   Loaded: loaded (/usr/lib/systemd/system/network.service; enabled)
   Active: active (exited) since Mon 2014-09-01 20:05:45 CST; 2h 14min ago
  Process: 1022 ExecStart=/etc/init.d/network start (code=exited, status=0/SUCCESS)
Sep 01 20:05:15 linux-pnp8 systemd[1]: Starting LSB: Configure network interfaces and set up routing...
Sep 01 20:05:15 linux-pnp8 network[1022]: Setting up network interfaces:
Sep 01 20:05:15 linux-pnp8 network[1022]: lo
Sep 01 20:05:15 linux-pnp8 network[1022]: lo        IP address: 127.0.0.1/8
Sep 01 20:05:45 linux-pnp8 network[1022]: ..done..done..doneSetting up service network  .  .  .  .  .  .  .  .  .  .  .  .  ...done
Sep 01 20:05:45 linux-pnp8 systemd[1]: Started LSB: Configure network interfaces and set up routing.
//centos下
 systemctl status httpd.service
httpd.service - The Apache HTTP Server (prefork MPM)
        Loaded: loaded (/lib/systemd/system/httpd.service; disabled)
        Active: inactive (dead)  <-- 表示未启动
        CGroup: name=systemd:/system/httpd.service
上面两个命令相当于/etc/init.d/network status 和 /etc/init.d/httpd status，opensuse和centos下的用法相同，只不过显示的路径不同。其他操作类似。
四、service配置文件
还以上面提到的httpd.service配置为例，httpd.service文件里可以找到如下行：
[Install]
WantedBy=multi-user.target
则表明在多用户目标（multi-user.target，相当于level3）时自动启动。如果想在runlevel 5下也自启动，则可以将配置改为如下：
[Install]
WantedBy=multi-user.target graphical.target
一旦设定了自动启动（enbale），就在/etc/systemd/system/.wants/下面建了一个httpd.service的软连接，连接到/lib/systemd/system/下的相应服务那里 。所以显示自动启动状态的unit （类似于chekconfig --list命令的结果），可以通过下面的方法：
ls /etc/systemd/system/multi-user.target.wants/
systemctl的总结先写到这里，其是systemd包内的一个工具，也是该包中最为常用的工具。回头再针对systemd做一个总结。
####补充[[详情可点击](http://blog.csdn.net/yangzhuoluo/article/details/5873272)]
&nbsp;&nbsp;&nbsp;&nbsp; Runlevel 可以认为是系统状态，形象一点，您可以认为 Runlevel 有点象微软的 Windows 操作系统中的正常启动（Normal）、安全模式（Safemode）和Command prompt only。进入每个 Runlevel 都需要启动或关闭相应的一系列服务（Services），这些服务（Services）以初始化脚本的方式放置于目录 /etc/rc.d/rc?.d/或者/etc/rc?.d下面。（?代表 Runlevel 的对应序号）。有如下几种运行级别：
运行级别（Runlevel）|系统状态(System state) 
--|--
0|Halt the system 停机（千万不要把 initdefault 设置为0），机器关闭
1|Single user mode 单用户模式，与 Win9x 下的安全模式类似
2|Basic multi user mode 基本多用户模式，没有 NFS 支持
3|Multi user mode 完整的多用户模式，是标准的运行级
4| None 一般不用，在一些特殊情况下可以用它来做一些事情。例如在笔记本电脑的电池用尽时，可以切换到这个模式来做一些设置。
5|Multi user mode with GUI 就是X11，进到XWindow系统了
6|Reboot the system 重新启动（千万不要把initdefault 设置为6），运行 init 6 机器就会重启
S| s Single user mode Runlevel 为 s 和 S 并不是直接给用户使用，而是用来 Single user mode 作准备。
1. 显示当前模式
	\$ runlevel
2. 切换运行命令
	\$ telinit 3
3. 在运行模式中加入启动服务
	要在某个运行模式中加入一个启动服务，首先要新建该服务启动脚本，然后把它放置于/etc/rc.d/init.d或者/etc/init.d/(根据你的 Linux版本有所不同)，要将该启动脚本与运行模式关联起来，你需要这个运行模式的目录下建立一个与/etc/rc.d/init.d/下启动脚本的 symbolic link，文件名的前缀通常为SXX，XX为数字，这个数字是用来控制该运行模式下服务的启动顺序。脚本的执行顺序是按照数字大小升序执行，就是数字越小越先执行，下面就是一个在运行模式中加入启动服务具体的例子：
	$ cp myservice /etc/rc.d/init.d/
	$ ln -s /etc/rc.d/init.d/myservice /etc/rc3.d/S99myservice
    这样，下次以Runlevel 3启动时，myservice就会自动启动。

 
