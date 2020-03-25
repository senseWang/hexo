---
title: lvs-详解
date: 2020-03-17 21:30:50
banner_img: https://sense-1301203133.cos.ap-beijing.myqcloud.com/homepahe/%E6%96%87%E7%AB%A0-linux%E5%9F%BA%E7%A1%80-%E5%B7%A5%E4%BD%9C.jpg
index_img: https://sense-1301203133.cos.ap-beijing.myqcloud.com/index-page/%E9%9D%99%E5%9B%BE%20%2814%29.jpg
tags:
- Linux
- Linux基础
- LVS
categories:
- Linux基础
---

# lvs详解



## 1、LVS基本原理

#### **简介：**

LVS 是基于 netfilter (iptables时有说过)框架，主要工作于 INPUT 链上，在 INPUT 上注册 `ip_vs_in` HOOK 函数，进行 IPVS 主流程，大概原理如图所示：

![](https://sense-1301203133.cos.ap-beijing.myqcloud.com/sense-linux/20200317164512.png)

* 当用户访问 www.sensewang.cn 时，用户数据通过层层网络，最后通过交换机进入 LVS 服务器网卡，并进入内核网络层。
* 进入 PREROUTING 后经过路由查找，确定访问的目的 VIP 是本机 IP 地址，所以数据包进入到 INPUT 链上

* IPVS 是工作在 INPUT 链上，会根据访问的 `vip+port` 判断请求是否 IPVS 服务，如果是则调用注册的 IPVS HOOK 函数，进行 IPVS 相关主流程，强行修改数据包的相关数据，并将数据包发往 POSTROUTING 链上。

* POSTROUTING 上收到数据包后，根据目标 IP 地址（后端服务器），通过路由选路，将数据包最终发往后端的真实服务器上。

#### 开源 LVS 版本有 3 种工作模式：

每种模式工作原理截然不同，说各种模式都有自己的优缺点，分别适合不同的应用场景，不过最终本质的功能都是能实现均衡的流量调度和良好的扩展性。主要包括以下三种模式：

- DR 模式
- NAT 模式
- Tunnel 模式

另外必须要说的模式是 FullNAT，这个模式在开源版本中是模式没有的，[代码](http://kb.linuxvirtualserver.org/wiki/IPVS_FULLNAT_and_SYNPROXY) 没有合并进入内核主线版本，后面会有专门章节详细介绍 FullNAT 模式。下边分别就 DR、NAT、Tunnel 模式分别详细介绍原理。



## DR模式

**DR模式实现原理(图出自CSDN，程序员肖邦)：**

![](https://sense-1301203133.cos.ap-beijing.myqcloud.com/sense-linux/20200317171136.png)

**从整个过程可以看出：**

DR 模式 LVS 逻辑非常简单，数据包通过路由方式直接转发给 RS，而且响应数据包是由 RS 服务器直接发送给客户端，不经过 LVS。我们知道一般请求数据包会比较小，响应报文较大，经过 LVS 的数据包基本上都是小包，上述几条因素是 LVS 的 DR 模式性能强大的主要原因。

**DR模式：**

采用半开放式的网络结构，与TUN模式结构类似，但各节点并不是分散在各地，而是与调度服务器位于同一个物理网络。负载调度器与各节点服务器通过本地网络连接，不需要建立专用的IP隧道。性能最高，安全性较高；

**优缺点和使用场景：**

* DR 模式的优点
  a. 响应数据不经过 lvs，性能高
  b. 对数据包修改小，信息保存完整（携带客户端源 IP）

* DR 模式的缺点
  a. lvs 与 rs 必须在同一个物理网络（不支持跨机房）
  b. rs 上必须配置 lo 和其它内核参数
  c. 不支持端口映射

* DR 模式的使用场景
  如果对性能要求非常高，可以首选 DR 模式，而且可以透传客户端源 IP 地址。



## NAT 模式

**lvs 的第 2 种工作模式是 NAT 模式，下图详细介绍了数据包从客户端进入 lvs 后转发到 rs，后经 rs 再次将响应数据转发给 lvs，由 lvs 将数据包回复给客户端的整个过程(图出自CSDN，程序员肖邦)。**

![](https://sense-1301203133.cos.ap-beijing.myqcloud.com/sense-linux/20200317202859.png)

**NAT 模式双向流量都经过 LVS，因此 NAT 模式性能会存在一定的瓶颈。不过与其它模式区别的是，NAT 支持端口映射，且支持 windows 操作系统。**

**优点、缺点与使用场景：**

* NAT 模式优点
  a. 能够支持 windows 操作系统
  b. 支持端口映射。如果 rs 端口与 vport 不一致，lvs 除了修改目的 IP，也会修改 dport 以支持端口映射。

* NAT 模式缺点
  a. 后端 RS 需要配置网关
  b. 双向流量对 lvs 负载压力比较大

* NAT 模式的使用场景
  如果你是 windows 系统，使用 lvs 的话，则必须选择 NAT 模式了。



## Tunnel 模式实现原理

**Tunnel 模式在国内使用的比较少，不过据说腾讯使用了大量的 Tunnel 模式。它也是一种单臂的模式，只有请求数据会经过 lvs，响应数据直接从后端服务器发送给客户端，性能也很强大，同时支持跨机房。下边继续看图分析原理。(图出自CSDN，程序员肖邦)**

![img](https://imgconvert.csdnimg.cn/aHR0cHM6Ly9yYXcuZ2l0aHVidXNlcmNvbnRlbnQuY29tL2xpd2VpMDUyNnZpcC9ibG9naW1nL21hc3Rlci9sYjAwN3R1bm5lbC5wbmc?x-oss-process=image/format,png)

**Tunnel 模式具备 DR 模式的高性能，又支持跨机房访问，听起来比较完美了。不过国内运营商有一定特色性，比如 RS 的响应数据包的源 IP 为 VIP，VIP 与后端服务器有可能存在跨运营商的情况，有可能被运营商的策略封掉。Tunnel 在生产环境确实没有使用过，在国内推行 Tunnel 可能会有一定的难度吧。**
**优点、缺点与使用场景：**

* Tunnel 模式的优点
  a. 单臂模式，对 lvs 负载压力小
  b. 对数据包修改较小，信息保存完整
  c. 可跨机房（不过在国内实现有难度）

* Tunnel 模式的缺点
  a. 需要在后端服务器安装配置 ipip 模块
  b. 需要在后端服务器 tunl0 配置 vip
  c. 隧道头部的加入可能导致分片，影响服务器性能
  d. 隧道头部 IP 地址固定，后端服务器网卡 hash 可能不均
  e. 不支持端口映射

* Tunnel 模式的使用场景
  理论上，如果对转发性能要求较高，且有跨机房需求，Tunnel 可能是较好的选择。



## 涉及的概念术语

* CIP：Client IP，表示的是客户端 IP 地址。
* VIP：Virtual IP，表示负载均衡对外提供访问的 IP 地址，一般负载均衡 IP 都会通过 Virtual IP 实现高可用
* RIP：RealServer IP，表示负载均衡后端的真实服务器 IP 地址。
* DIP：Director IP，表示负载均衡与后端服务器通信的 IP 地址。
* CMAC：客户端的 MAC 地址，准确的应该是 LVS 连接的路由器的 MAC 地址。
* VMAC：负载均衡 LVS 的 VIP 对应的 MAC 地址。
* DMAC：负载均衡 LVS 的 DIP 对应的 MAC 地址。
* RMAC：后端真实服务器的 RIP 地址对应的 MAC 地址。


[本文摘自CSDN，程序员肖邦](https://blog.csdn.net/liwei0526vip/article/details/103104483)
  
  
