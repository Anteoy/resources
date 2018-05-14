---
id: 68
date: 2018-05-14 12:22:00
title: ubuntu 16.04 解决有线网卡驱动Exec format error问题
categories:
    - ubuntu
tags:
    - ubuntu,linux,Exec format error
---

### 前言   
ubuntu 16.04的工作本,有线网卡总是出一些比较坑的问题,比如有时候能用有时候突然又不能用了,有时候开机没问题正常使用,有时候开机完全找不到有线连接,同时,**个人使用习惯会经常休眠,而休眠唤醒过后,有线网就肯定不能用了**.原本比较少用有线网络,这个工作本的有线网络也没有怎么管它.另外这个本也有好几年了,原本以为是网卡接口接触不良,最近公司的无线网络越来越难用,越来越慢,于是就好好看了下这个有线网卡的问题.
### 驱动问题   
稍做检查,发现是ubuntu在安装的时候,默认装的驱动居然不是最适配的驱动(最后发现这是一个坑,因为我手动也无法装上官网最适合的驱动,估计ubuntu发现自己无法装最适合的,自主切换为另一个有问题的驱动)   
**lspci -v**   
```
0e:00.0 Ethernet controller: Realtek Semiconductor Co., Ltd. RTL8111/8168/8411 PCI Express Gigabit Ethernet Controller (rev 0c)
	DeviceName: Hanksville Gbe Lan Connection
	Subsystem: Hewlett-Packard Company RTL8111/8168/8411 PCI Express Gigabit Ethernet Controller
	Flags: bus master, fast devsel, latency 0, IRQ 28
	I/O ports at 2000 [size=256]
	Memory at d3500000 (64-bit, non-prefetchable) [size=4K]
	Memory at d3400000 (64-bit, prefetchable) [size=16K]
	Capabilities: [40] Power Management version 3
	Capabilities: [50] MSI: Enable+ Count=1/1 Maskable- 64bit+
	Capabilities: [70] Express Endpoint, MSI 01
	Capabilities: [b0] MSI-X: Enable- Count=4 Masked-
	Capabilities: [d0] Vital Product Data
	Capabilities: [100] Advanced Error Reporting
	Capabilities: [140] Virtual Channel
	Capabilities: [160] Device Serial Number 01-00-00-00-68-4c-e0-00
	Capabilities: [170] Latency Tolerance Reporting
	Kernel driver in use: r8169
	Kernel modules: r8169
```
**RTL8111/8168/8411 用的r8169的驱动**
发现驱动不对,然后在官网找到对应适合驱动[地址](http://www.realtek.com.tw/downloads/downloadsView.aspx?Langid=1&PNid=5&PFid=5&Level=5&Conn=4&DownTypeID=3&GetDown=false)  
找到**LINUX driver for kernel up to 4.7
8.045	2017/9/15	101k	Global**点击global进行下载.
### Exec format error
原本以为按照README中的安装步骤进行编译安装会顺丰顺水.结果遇到了一个坑   
按照README的说明:   
**sudo ./autorun.sh**  
报错:
```
ERROR: could not insert 'r8168': Exec format error
```
这个问题着实有点坑,google了好几种方法都不尽人意,无法解决.直到我后来又去下载页面看了下说明:   
**LINUX driver for kernel up to 4.7**   
what? **for kernel up to 4.7** 看字面上的意思是up to 4.7,理论上内核4.7及以下都应该支持这个驱动才对,不过抱着姑且一试的态度,计划把原本4.4的内核升级到4.7,想着官方提到4.7,那么4.7版本的内核理论上肯定是通过他们官方的测试的.
### 安装kernel4.7内核
到这个页面,下载对应的deb包,比如我这里下载的是amd64:   
[http://kernel.ubuntu.com/~kernel-ppa/mainline/v4.7/](http://kernel.ubuntu.com/~kernel-ppa/mainline/v4.7/)
然后:   
```
sudo dpkg -i linux*.deb
```   
需要稍微等待几分钟,然后安装完成.   
**重新启动,注意需要选择用内核4.7启动系统**   
然后: **uname -a**
```
Linux zhoudazhuang-pc 4.7.0-040700-generic #201608021801 SMP Tue Aug 2 22:03:09 UTC 2016 x86_64 x86_64 x86_64 GNU/Linux
```   
安装4.7内核成功.   
然后按照README的安装文档在此执行:   
```
sudo ./autorun.sh
```   
这次不会再报错了,并且使用:
```
modinfo r8168
```  
显示:   
```
filename:       /lib/modules/4.7.0-040700-generic/kernel/drivers/net/ethernet/realtek/r8168.ko
version:        8.045.08-NAPI
license:        GPL
description:    RealTek RTL-8168 Gigabit Ethernet driver
author:         Realtek and the Linux r8168 crew <netdev@vger.kernel.org>
srcversion:     83F0B464A28DB94AB899112
alias:          pci:v00001186d00004300sv00001186sd00004B10bc*sc*i*
alias:          pci:v000010ECd00008161sv*sd*bc*sc*i*
alias:          pci:v000010ECd00008168sv*sd*bc*sc*i*
depends:        
vermagic:       4.7.0-040700-generic SMP mod_unload modversions 
parm:           speed_mode:force phy operation. Deprecated by ethtool (8). (uint)
parm:           duplex_mode:force phy operation. Deprecated by ethtool (8). (uint)
parm:           autoneg_mode:force phy operation. Deprecated by ethtool (8). (uint)
parm:           aspm:Enable ASPM. (int)
parm:           s5wol:Enable Shutdown Wake On Lan. (int)
parm:           s5_keep_curr_mac:Enable Shutdown Keep Current MAC Address. (int)
parm:           rx_copybreak:Copy breakpoint for copy-only-tiny-frames (int)
parm:           use_dac:Enable PCI DAC. Unsafe on 32 bit PCI slot. (int)
parm:           timer_count:Timer Interrupt Interval. (int)
parm:           eee_enable:Enable Energy Efficient Ethernet. (int)
parm:           hwoptimize:Enable HW optimization function. (ulong)
parm:           s0_magic_packet:Enable S0 Magic Packet. (int)
parm:           debug:Debug verbosity level (0=none, ..., 16=all) (int)

```   

### 其他   
1. lsmod(list modules)指令,会列出所有已载入系统的模块。
2. lspci 是一个用来显示系统中所有PCI总线设备或连接到该总线上的所有设备的工具。 参数: -v 使得 lspci 以冗余模式显示所有设备的详细信息。
3. insmod命令-,install module的缩写,用来载入模块,通过模式的方式在需要时载入内核,可使内核精简,高效。在Linux中，modprobe和insmod都可以用来加载module，不过现在一般都推荐使用modprobe而不是insmod了。
modprobe和insmod的区别是什么呢？
- modprobe可以解决load module时的依赖关系，比如load moudleA就必须先load mouduleB之类的，它是通过/lib/modules//modules.dep文件来查找依赖关系的。而insmod不能解决依赖问题。
- modprobe默认会去/lib/modules/目录下面查找module，而insmod只在给它的参数中去找module（默认在当前目录找）。eg: **modprobe -v r8168**
4. ifconfig eno1 down/up

### 参考   
1. [https://askubuntu.com/questions/829769/i-want-to-use-the-linux-4-7-kernel-in-16-04-01-where-can-i-find-the-repo](https://askubuntu.com/questions/829769/i-want-to-use-the-linux-4-7-kernel-in-16-04-01-where-can-i-find-the-repo)
2. [https://medium.com/@lgobinath/no-ethernet-connection-in-ubuntu-16-04-linux-mint-18-with-realtek-rtl8111-8168-8411-7ae2779dc9b8](https://medium.com/@lgobinath/no-ethernet-connection-in-ubuntu-16-04-linux-mint-18-with-realtek-rtl8111-8168-8411-7ae2779dc9b8)