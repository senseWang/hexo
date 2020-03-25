---
title: iptables-详解
date: 2020-03-17 8:54:50
banner_img: https://sense-1301203133.cos.ap-beijing.myqcloud.com/homepahe/%E6%96%87%E7%AB%A0-linux%E5%9F%BA%E7%A1%80-%E5%B7%A5%E4%BD%9C.jpg
index_img: https://sense-1301203133.cos.ap-beijing.myqcloud.com/index-page/%E9%9D%99%E5%9B%BE%20%2812%29.jpg
tags:
- Linux
- Linux基础
- iptables
categories:
- Linux基础
---
# iptables-详解


## 防火墙介绍

#### 逻辑上讲：

主机防火墙：针对单个主机进行防护，不影响其他host

网络防火墙：往往处于网络入口或边缘，针对于网络入口进行防护，影响局域网内的主机

总结：网络防火墙和主机防火墙并不冲突，可以理解为，网络防火墙主外(集体)，主机防火墙主内(个人)。

#### 从物理上讲：

硬件防火墙:在硬件级别实现部分防火墙功能，另-部分功能基于软件实现， 性能高，成本高。
软件防火墙:应用软件处理逻辑运行于通用硬件平台之上的防火墙,性能低,成本低。

总结：追求严格安全选硬件，追求普通安全选软件

#### iptables和netfilter：

iptables(存在用户空间)是netfilter(存在内核空间)框架提供的一个客户端代理(命令行工具)，使用iptables可以将用户对于的规则执行到安全框架中(指netfilter)

netfilter是linux系统核心层内部的一个数据包处理模块，具备功能如下：

* 网络地址转换
* 数据包内容修改
* 包过滤的防火墙功能

##### 总结：iptables并不是一个服务，因为它没有任何后台，只能算是netfilter提供的一个功能



## iptables基础

#### **iptables工作原理：**

我们知道iptables是按照规则来办事的,我们就来说说规则(rules) ， 规则其实就是网络管理员预定义的条件。往往使用到IP地址、端口、各传输协议、各服务类型时，这些都可以被放到规则中，来实现是否被允许。

#### **客户端经过iptables后访问服务器的完整流程：**

但我们启用防火墙功能时，客户端请求报文就会经过各个关卡，就是所谓的链。看得出根据实际情况的不同经历的关卡(链)也会有所不同。   如果报文需要转发，那么报文则不会经过input链发往用户空间,而是直接在内核空间中经过forward链和postrouting链转发出去的。

![](https://sense-1301203133.cos.ap-beijing.myqcloud.com/sense-linux/客户端经过iptables到服务器.png)

**根据上图，不同场景的报文流向如下：**

* 到本机某进程的报文: PREROUTING --> INPUT
* 由本机转发的报文: PREROUTING --> FORWARD --> POSTROUTING
* 由本机的某进程发出报文(通常为响应报文) : OUTPUT --> POSTROUTING

**小结：防火墙是层层过滤的，通过匹配上规则来允许或者组织数据包的走向**



## 链的概念

#### **链**：

对于一个报文，可能针对的规则是有很多的，每个规则都会执行对应的动作，而这些规则会“串”在一起，串成了链。每个报文，当经历到对应的关卡(链)时，都会将这个链上串的规则走一遍，这就是规则和链的关系。如下图：

![](https://sense-1301203133.cos.ap-beijing.myqcloud.com/sense-linux/iptables链和规则.png)



## 表的概念

#### 表：

一句话，表是链的容器，每个链都属于对应的表。

**什么意思：**我们想想，既然每个规则可以被链串在一起，那么链也同样可以被集合到一起，称为表。

**如下图：**

![](https://sense-1301203133.cos.ap-beijing.myqcloud.com/sense-linux/20200317082802.png)

#### **每个表的功能：**

**filter表:** 负责过滤功能，防火墙;内核模块: iptables_ filter
**nat表:**  network address translation,网络地址转换功能;内核模块: iptable_ nat
**mangle表:** 拆解报文,做出修改，并重新封装的功能; iptable_ mangle
**raw表: **关闭nat表上启用的连接追踪机制; iptable_ raw
**总结：**也就是说，我们自定义的所有规则，都是这四种分类中的规则，或者说，所有规则都存在于这4张"表"中。



## 表和链的关系

#### 关系：

但是我们需要注意的是，些"链"中注定不会包含‘某类规则"，就像某些"关卡"天生就不具备某些功能一样。那让我们来看看，每个"关卡"都有哪些能力，或者说，让我们看看每个"链"上的规则都存在于哪些"表"中。

#### 表和链的包含关系：

**raw表中的规则：**可以被哪些链使用: PREROUTING, OUTPUT
**mangle表中的规则：**可以被哪些链使用: PREROUTING, INPUT, FORWARD, OUTPUT, POSTROUTING
**nat表中的规则：**可以被哪些链使用: PREROUTING， OUTPUT, POSTROUTING (centos7中还有INPUT, centos6中没有)
**filter 表中的规则：**可以被哪些链使用: INPUT, FORWARD, OUTPUT

![](https://sense-1301203133.cos.ap-beijing.myqcloud.com/sense-linux/20200317082802.png)



## 规则的概念

#### 规则：

根据指定的匹配条件来尝试匹配每个流经此处的报文，一旦匹配成功，则由规则后面指定的处理动作进行处理;

#### 规则的结构：由匹配条件和处理动作组成

**匹配条件：**分为基本条件和扩展匹配条件

* 基本条件
  * 源地址和目标地址
* 扩展匹配条件
  * 源端口和目标端口



**处理动作：**动作也可以分为基本动作和扩展动作。
此处列出一些常用的动作：
`ACCEPT`: 允许数据包通过。
`DROP`: 直接丢弃数据包，不给任何回应信息，这时候客户端会感觉自己的请求泥牛入海了，过了超时时间才会有反应。
`REJECT`: 拒绝数据包通过,必要时会给数据发送端一个响应的信息， 客户端刚请求就会收到拒绝的信息。
`SNAT`: 源地址转换，解决内网用户用同-个公网地址上网的问题。
`MASQUERADE`: 是SNAT的一种特殊形式，适用于动态的、临时会变的ip上。
`DNAT`: 目标地址转换。
`REDIRECT`: 在本机做端口映射。
`LOG`: 在/var/log/messages文件中记录日志信息， 然后将数据包传递给下一条规则， 也就是说除了记录以外不对数据包做任何其他操作，仍然让下一条规则去匹配。



[本文观自大佬：朱双印](http://www.zsythink.net/)
