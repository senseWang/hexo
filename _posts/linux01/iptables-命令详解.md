---
title: iptables-命令详解
date: 2020-03-17 13:54:50
banner_img: https://sense-1301203133.cos.ap-beijing.myqcloud.com/homepahe/%E6%96%87%E7%AB%A0-linux%E5%9F%BA%E7%A1%80-%E5%B7%A5%E4%BD%9C.jpg
index_img: https://sense-1301203133.cos.ap-beijing.myqcloud.com/index-page/%E9%9D%99%E5%9B%BE%20%2813%29.jpg
tags:
- Linux
- Linux基础
- iptables
categories:
- Linux基础
---

[TOC]

# iptables-命令详解



## iptables命令常见选项参数

#### **表及链的操作选项：**

`-N `：新增链

`-I` ： 插入规则

`-A `：添加规则

`-D` ：删除规则

`-R` ：修改某条规则

`-X` ：删除自定义的链（前提为该链被引用次数为0及规则为空）

`-F` ：清除所有规则

`-Z`：清零 （清除所有链的计数值）

`-P` ：定义默认规则（ACCEPT，DROP，REJECT..)

`-L `：列出所有规则

  `-v`：列出详细信息

  `-n`：以数字方式显示信息

  常用：iptables -vnL

`-E`：改变链名称

#### **规则匹配相关选项：**

`　-s ` ：源地址（例：192.168.2.0/16)

`-d`  ：目标地址

`--dport` ：目标端口（例：137:140为137～140所有端口，可单独指定某个端口）

`--sport`  ：源端口

`-p` ：指定protocol (例 tcp,udp ,..)

`-i` ：入方向网卡接口

`-o` ：出方向网卡接口

``-m multiport `：指定多个端口



## 1、查看防火墙规则

```bash
[root@server ~]# iptables -vnL -t nat		#查看指定表的规则，默认是filter
[root@server ~]# iptables -L -n --line-numbers		#显示序号，删除时和配合使用
```

## 2、清理参数

```bash
[root@server ~]# iptables -F					#清除所有防火墙规则
[root@server ~]# iptables -N 链名				#创建自定义链
[root@server ~]# iptables -X 链名				#删除用户自定义链
[root@server ~]# iptables -Z					#对链计数器清零
[root@server ~]# iptables -D OUTPUT  2			#按照编号删除指定规则
```

## 3、禁止规则

```bash
[root@server ~]# iptables -t filter -A INPUT  -p tcp --dport 22 -j DROP		#禁止22号端口连接   -t 指定表 -A 追加 -p 指定协议 --dport 指定目的端口 -j 采取的方式
[root@server ~]# iptables -t filter -A INPUT -p tcp --dport 80 -j DROP		#会造成找不到网页不会造成404
```

## 4、案例演示

| 系统    | IP            | 主机名              | 角色   |
| ------- | ------------- | ------------------- | ------ |
| centos7 | 192.168.100.1 | server.sensewang.cn | server |
| centos7 | 192.168.100.3 | node2.sensewang.cn  | client |

## 5、FIlter常见规则

### 5.1主机防火墙

主机防火墙，就是在指定主机上配置规则，作用范围是本主机。

**环境准备，为了更好的看出效果**

**100.1安装httpd并创建网页**

```bash
[root@server ~]# yum -y install httpd
[root@server ~]# systemctl start httpd
[root@server ~]# echo "www.sensewang.cn" > /var/www/html/index.html
```

**100.3访问测试**

```bash
[root@node ~]# curl 192.168.100.1
www.sensewang.cn
```

**由于实际使用中，为安全起见，更常用的是做"白名单"，所以，将100.1主机iptables默认策略设置为DROP，匹配顺序是，先匹配定义规则后匹配默认规则**

```bash
[root@server ~]# iptables -A INPUT -p tcp --dport 22 -j ACCEPT && iptables -A OUTPUT -p tcp --sport 22 -j ACCEPT		#先保证xshell不会断
[root@server ~]# iptables -P FORWARD DROP
[root@server ~]# iptables -P INPUT DROP
[root@server ~]# iptables -P OUTPUT DROP
```



#### 5.1.1 指定主机访问

**主机100.3无法访问100.1因为默认策略是drop**

```bash
[root@node ~]# curl 192.168.100.1
………………
```

**100.1上添加允许对100.3的访问**

开放放行是双向的：不仅要放行客户端发来的请求报文，还要放行目标地址是客户端地址的响应报文。否则客户端仍接收不到。

```bash
[root@server ~]# iptables -A INPUT -s 192.168.100.3 -j ACCEPT
[root@server ~]# iptables -A OUTPUT -d 192.168.100.3 -j ACCEPT
```

100.3访问

```bash
[root@node ~]# curl 192.168.100.1
www.sensewang.cn
```



#### 5.1.2 指定端口访问

通过开放端口，来对外提供服务。

**将httpd监听端口进行修改，以便看出效果**

```bash
[root@server ~]# vim /etc/httpd/conf/httpd.conf #修改如下
Listen 80
Listen 6666
Listen 8888
[root@server ~]# systemctl restart httpd
```

**删除5.1.1中的两条规则，以验证效果**

```bash
[root@server ~]# iptables -nvL --line-numbers		#查看规则对应的编号，然后根据编号进行删除
[root@server ~]# iptables -D OUTPUT  <num>			#按照编号删除指定规则
```

**开放6666、8888端口，但不开放80**

```bash
[root@server ~]# iptables -A INPUT -p tcp -m multiport --dports 6666,8888 -j ACCEPT
[root@server ~]# iptables -A OUTPUT -p tcp -m multiport --sports 6666,8888 -j ACCEPT
```

**100.3访问测试、开放的端口正常服务，80则不行**

```bash
[root@node ~]# curl 192.168.100.1:8888
www.sensewang.cn
[root@node ~]# curl 192.168.100.1:6666
www.sensewang.cn
[root@node ~]# curl 192.168.100.1
^C
```



#### 5.1.3限制ping报文

实现：100.1主机可以ping通100.3主机，但100.3主机不能ping通100.1主机。

**由于100.1主机的默认策略是DROP，所以ping不通100.3主机，100.3主机也ping不通100.1。**

```bash
[root@server ~]# ping 192.168.100.3
PING 192.168.100.3 (192.168.100.3) 56(84) bytes of data.
ping: sendmsg: 不允许的操作
ping: sendmsg: 不允许的操作
[root@node ~]# ping 192.168.100.1
PING 192.168.100.1 (192.168.100.1) 56(84) bytes of data.
………………
```

**1、在100.1主机，设置OUTPUT链放行ping请求报文，INPUT链放行ping回应报文：**

```bash
[root@server ~]# iptables -A OUTPUT -p icmp --icmp-type 8 -j ACCEPT #icmp 8类型为请求报文
[root@server ~]# iptables -A INPUT -p icmp --icmp-type 0 -j ACCEPT  # 0类型为应答报文
```

**ping测试**

```bash
[root@server ~]# ping 192.168.100.3
PING 192.168.100.3 (192.168.100.3) 56(84) bytes of data.
64 bytes from 192.168.100.3: icmp_seq=1 ttl=64 time=0.151 ms
…………
[root@node ~]# ping 192.168.100.1
PING 192.168.100.1 (192.168.100.1) 56(84) bytes of data.
……………
```

**2、想要让100.3ping：100.1的INPUT链为请求报文入的口；OUTPUT链为应答报文出的口**

```bash
[root@server ~]# iptables -A INPUT -p icmp --icmp-type 8 -j ACCEPT
[root@server ~]# iptables -A OUTPUT -p icmp --icmp-type 0 -j ACCEPT
```

**ping测试**

```bash
[root@server ~]# ping 192.168.100.3
PING 192.168.100.3 (192.168.100.3) 56(84) bytes of data.
64 bytes from 192.168.100.3: icmp_seq=1 ttl=64 time=0.151 ms
…………
[root@node ~]# ping 192.168.100.1
PING 192.168.100.1 (192.168.100.1) 56(84) bytes of data.
64 bytes from 192.168.100.1: icmp_seq=1 ttl=64 time=0.270 ms
…………
```



#### 5.1.4 现中包含指定字符的报文

**目的：是令100.3主机访问100.1主机的http服务，有字符串“world”的页面不能被访问，没有数字的正常**

**为对比效果，在100.1上添加一个html网页如下：**

```bash
[root@server ~]# echo "hello world" > /var/www/html/string.html
```

**清空之前的规则，回到默认策略为DROP的时候。放行访问100.1主机的报文，放行100.1主机回应的报文:**

```bash
[root@server ~]# iptables -A INPUT -d 192.168.100.1 -j ACCEPT
[root@server ~]# iptables -A OUTPUT -s 192.168.100.1 -j ACCEPT
```

**100.3访问测试：**

```bash
[root@node ~]# curl 192.168.100.1/index.html
www.sensewang.cn
[root@node ~]# curl 192.168.100.1/string.html
hello world
```

**在100.1主机，定义页面内容中匹配到字符串world的，不予回应。注意，要定义在OUTPUT链，INPUT链只能作用到请求报文，而请求报文是否有数字也是无法预知的：**

```bash
#编写规则，注意，要用-I插入到第一行，因为规则是从上往下依次走的
[root@server ~]# iptables -I OUTPUT 1 -s 192.168.100.1 -m string --algo bm --string world -j REJECT
```

**100.3访问测试**

```bash
[root@node ~]# curl 192.168.100.1/index.html
www.sensewang.cn
[root@node ~]# curl 192.168.100.1/string.html
^C
```



#### 5.1.5 限制主机发起的链接数

```bash
[root@server ~]# iptables -F
[root@server ~]# iptables -A OUTPUT -s 192.168.100.1 -j ACCEPT
[root@server ~]# iptables -A INPUT -d 192.168.100.1 -m connlimit ! --connlimit-above 2 -j ACCEPT			#只允许两个链接
```

100.3链接测试：只有两个终端能链接，第三个就不行了

![](https://sense-1301203133.cos.ap-beijing.myqcloud.com/sense-linux/20200317124602.png)



#### 5.1.6 限制报文速率

下面操作目的，是令从100.3主机，访问100.1主机的报文，以指定速率访问：

清空之前的规则后，放行目标IP是100.1的报文，并放行100,1的响应报文：

```bash
[root@server ~]# iptables -A OUTPUT -s 192.168.100.1 -j ACCEPT
[root@server ~]# iptables -A INPUT -d 192.168.100.1 -j ACCEPT
```

100.3平100.1，查看正常速率

![](https://sense-1301203133.cos.ap-beijing.myqcloud.com/sense-linux/20200317125913.png)

100.1进行规则限制，把第刚刚放行规则的允许访问，变为允许访问且限制接收报文速率为每分钟8个，峰值速率3（默认是5）

```bash
[root@server ~]# iptables -R INPUT 2 -d 192.168.100.1 -m limit --limit 8/minute --limit-burst 3 -j ACCEPT
```

这时再用100.3主机ping，间隔时间就会变长了（前3个的间隔不会变长，因为有峰值速率3）：

![](https://sense-1301203133.cos.ap-beijing.myqcloud.com/sense-linux/20200317130601.png)



### 5.2 网络防火墙

#### 5.2.1 案例环境及介绍

**介绍：**一主机处于某网络的边缘，该网络进出报文都经过该主机。则可在这个主机设置规则，按条件过滤进出此网络的报文。

**特点：**和主机防火墙不同的是，网络防火墙主机中的进程往往不会和其他主机通信，仅仅是转发其他主机的报文。所以要达到过滤目的，规则要设置在FORWARD链上。INPUT和OUTPUT链上的规则对转发的报文不起作用。

**案例图：**

![](https://sense-1301203133.cos.ap-beijing.myqcloud.com/sense-linux/20200317143818.png)

案例主机表格：

| 系统    | ip                                         | 主机名              | 角色           |
| ------- | ------------------------------------------ | ------------------- | -------------- |
| centos7 | 192.168.100.1    网关：192.168.100.2       | node1.sensewang.cn  | 客户端         |
| centos7 | 192.168.100.2    ens37：192.168.200.2      | server.sensewang.cn | 公司网关服务器 |
| centos7 | 192.168.200.1          网关：192.168.200.2 | node2sensewang.cn   | 公司web服务器  |

**开启server的路由转发，并验证nodes的连通性**

```bash
[root@server ~]# vim /etc/sysctl.conf 
net.ipv4.ip_forward = 1
[root@server ~]# sysctl  -p
[root@node1 ~]# ping 192.168.200.1
PING 192.168.200.1 (192.168.200.1) 56(84) bytes of data.
64 bytes from 192.168.200.1: icmp_seq=1 ttl=63 time=0.323 ms
64 bytes from 192.168.200.1: icmp_seq=2 ttl=63 time=0.423 ms
…………
[root@node2 ~]# ping 192.168.100.1
PING 192.168.100.1 (192.168.100.1) 56(84) bytes of data.
64 bytes from 192.168.100.1: icmp_seq=1 ttl=63 time=0.231 ms
64 bytes from 192.168.100.1: icmp_seq=2 ttl=63 time=0.384 ms
……
```



#### 5.2.2  验证效果

**首先关闭node1和node2的iptables。然后把server的iptables默认策略设置为DROP，并验证连通性**

```bash
[root@server ~]# iptables -F 
[root@server ~]# iptables -P FORWARD DROP
[root@node1 ~]# ping 192.168.200.1					#无法连通
PING 192.168.200.1 (192.168.200.1) 56(84) bytes of data.
^C
[root@node2 ~]# ping 192.168.100.1
PING 192.168.100.1 (192.168.100.1) 56(84) bytes of data.
^C
```

**下面验证server防火墙功能：**

**1、下面令内网node1能ping通node2，node2ping不通内网node1。只需在server操作：**

```bash
[root@server ~]# iptables -A FORWARD -s 192.168.100.0/24 -p icmp --icmp-type 8 -j ACCEPT
[root@server ~]# iptables -A FORWARD -d 192.168.100.0/24 -p icmp --icmp-type 0 -j ACCEPT
```

**2、node1和node2相ping的效果**

```bash
[root@node1 ~]# ping 192.168.200.1
PING 192.168.200.1 (192.168.200.1) 56(84) bytes of data.
64 bytes from 192.168.200.1: icmp_seq=1 ttl=63 time=0.218 ms
64 bytes from 192.168.200.1: icmp_seq=2 ttl=63 time=0.277 ms
^C
[root@node2 ~]# ping 192.168.100.1
PING 192.168.100.1 (192.168.100.1) 56(84) bytes of data.
^C
```

**3、进一步，使用tcpdump抓包验证。当node1去ping node2时，报文均正常放行。**

**但在node2去ping node1时，分别在不同网卡，可验证防火墙作用：**

首先启动node2的另一终端，而后在node3网卡上抓包，可看到从该网卡流出的ping请求，但没有ping回应

```bash
[root@node2 ~]# tcpdump  -i ens33 -nn icmp 
tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on ens33, link-type EN10MB (Ethernet), capture size 262144 bytes
06:09:56.487934 IP 192.168.200.1 > 192.168.100.1: ICMP echo request, id 2106, seq 1, length 64
06:09:57.487130 IP 192.168.200.1 > 192.168.100.1: ICMP echo request, id 2106, seq 2, length 64
06:09:58.487275 IP 192.168.200.1 > 192.168.100.1: ICMP echo request, id 2106, seq 3, length 64
06:09:59.487316 IP 192.168.200.1 > 192.168.100.1: ICMP echo request, id 2106, seq 4, length 64
06:10:00.487206 IP 192.168.200.1 > 192.168.100.1: ICMP echo request, id 2106, seq 5, length 64
06:10:01.487237 IP 192.168.200.1 > 192.168.100.1: ICMP echo request, id 2106, seq 6, length 64
^C
```

在node1，没有收到node2的ping请求

```bash
[root@node1 ~]# tcpdump -i ens33 -nn |grep 192.168.100.1
tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on ens33, link-type EN10MB (Ethernet), capture size 262144 bytes
^C6 packets captured
```

在server的ens37，收到了node2的ping请求；在server的ens33，却没有，说明在中间被过滤了：

```bash
[root@server ~]# tcpdump -i ens37 -nn |grep 192.168.200.1
tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on ens37, link-type EN10MB (Ethernet), capture size 262144 bytes
06:14:52.372022 IP 192.168.200.254.11049 > 192.168.200.1.22: Flags [P.], seq 899467132:899467176, ack 973268412, win 4103, length 44
06:14:52.372186 IP 192.168.200.1.22 > 192.168.200.254.11049: Flags [.], ack 44, win 252, length 0
06:14:52.372285 IP 192.168.200.1.22 > 192.168.200.254.11049: Flags [P.], seq 1:53, ack 44, win 252, length 52
06:14:52.412472 IP 192.168.200.254.11049 > 192.168.200.1.22: Flags [.], ack 53, win 4102, length 0
06:14:52.633154 IP 192.168.200.254.11049 > 192.168.200.1.22: Flags [P.], seq 44:80, ack 53, win 4102, length 36
…………
[root@server ~]# tcpdump -i ens33 -nn |grep 192.168.200.1
tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on ens33, link-type EN10MB (Ethernet), capture size 262144 bytes
^C96 packets captured
```

**4、如果把node2到node1的ping请求也开放，添加规则：**

```bash
[root@server ~]# iptables -A FORWARD -p icmp --icmp-type 8 -d 192.168.100.1 -j ACCEPT
```

则可在node1看到node2的ping请求，和给node2的ping回应：

```bash
[root@node1 ~]# tcpdump -i ens33 -nn |grep 192.168.100.1
tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on ens33, link-type EN10MB (Ethernet), capture size 262144 bytes
06:24:03.909324 IP 192.168.100.1.22 > 192.168.100.254.11052: Flags [P.], seq 3755136105:3755136293, ack 1523680694, win 252, length 188
06:24:03.909785 IP 192.168.100.254.11052 > 192.168.100.1.22: Flags [.], ack 188, win 4104, length 0
06:24:05.301999 IP 192.168.200.1 > 192.168.100.1: ICMP echo request, id 2120, seq 1, length 64
06:24:05.302021 IP 192.168.100.1 > 192.168.200.1: ICMP echo reply, id 2120, seq 1, length 64
06:24:06.301955 IP 192.168.200.1 > 192.168.100.1: ICMP echo request, id 2120, seq 2, length 64
```

但此时node2仍收不到响应报文，因为给node2的响应没有放行。在server的ens37可看到还是只有node2的请求报文：

```bash
[root@server ~]# tcpdump -i ens37 -nn |grep 192.168.200.1
tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on ens37, link-type EN10MB (Ethernet), capture size 262144 bytes
06:26:31.283180 IP 192.168.200.1 > 192.168.100.1: ICMP echo request, id 2120, seq 148, length 64
06:26:32.282864 IP 192.168.200.1 > 192.168.100.1: ICMP echo request, id 2120, seq 149, length 64
06:26:33.283402 IP 192.168.200.1 > 192.168.100.1: ICMP echo request, id 2120, seq 150, length 64
06:26:34.284331 IP 192.168.200.1 > 192.168.100.1: ICMP echo request, id 2120, seq 151, length 64
```

在server再添加规则，放行由内网node1响应的报文：

```bash
[root@server ~]# iptables -A FORWARD -p icmp --icmp-type 0 -s 192.168.100.0/24 -j ACCEPT
```

则此时node2可以收到node1 的回应

```bash
[root@node2 ~]# ping 192.168.100.1
PING 192.168.100.1 (192.168.100.1) 56(84) bytes of data.
64 bytes from 192.168.100.1: icmp_seq=1 ttl=63 time=0.427 ms
64 bytes from 192.168.100.1: icmp_seq=2 ttl=63 time=0.406 ms
…………
```



## 6、nat 常见规则

**案例环境：**

| 系统    | ip                                    | 主机名              | 角色           |
| ------- | ------------------------------------- | ------------------- | -------------- |
| centos7 | 192.168.100.1    网关：192.168.100.2  | node1.sensewang.cn  | 客户端         |
| centos7 | 192.168.100.2    ens37：192.168.200.2 | server.sensewang.cn | 公司网关服务器 |
| centos7 | 192.168.200.1    网关：192.168.200.2  | node2sensewang.cn   | 公司web服务器  |

### 6.1 源地址转换

**client访问web服务器时，简单的报文流向，如图：**

![](https://sense-1301203133.cos.ap-beijing.myqcloud.com/sense-linux/20200318141004.png)

**报文流向：**
1、报文从node1到达server的ens33；
2、在server进行源地址转换后，从server发送至node2；
3、node2响应报文给server（是server，因为是用server的地址访问的，node1并不知道node2）；
4、在server进行目标地址转换后（目标地址由server转换为node1的地址），发送至node1.

**下面通过设置源地址转换规则，tcpdump抓包，验证node1访问node2时，被server把源地址转换为自己的ens37的地址的效果：**

**1、避免上个实验中案例留下来的残余,影响效果。将规则清空，并把各表的策略设置为ACCEPT(过程略)**

**2、启动node2的httpd，在测试页面写入内容：**

```bash
[root@node2 ~]# yum -y install httpd
[root@node2 ~]# systemctl start httpd
[root@node2 ~]# echo "www.sensewang.cn" > /var/www/html/index.html
```

**3、因为此时server转发功能打开，且没有开启防火墙，所以node1是直接可以访问到的**：

```bash
[root@node1 ~]# curl 192.168.200.1
www.sensewang.cn
```

在node2上的httpd的访问日志中，可以看到客户端IP是192.168.100.1 的：

```bash
[root@node2 ~]# tail /var/log/httpd/access_log 
192.168.100.1 - - [18/Mar/2020:22:20:58 +0800] "GET / HTTP/1.1" 200 17 "-" "curl/7.29.0"
```

**4、在server的POSTROUTING链，设置源地址为192.168.100.0/24网段的主机，均转换为server的ens37的地址10.0.0.2：**

```bash
[root@server ~]# iptables -t nat -A POSTROUTING -s 192.168.100.0/24 -j SNAT --to-source 10.0.0.2
```

此时使用node1访问node2的http页面，访问日志记录的客户端IP就变为10.0.0.2：

```bash
#node1
[root@node1 ~]# curl 192.168.200.1
www.sensewang.cn
#node2
[root@node2 ~]# tail -1 /var/log/httpd/access_log 
10.0.0.2 - - [18/Mar/2020:22:30:34 +0800] "GET / HTTP/1.1" 200 17 "-" "curl/7.29.0"
```

#### 

### 6.2 目标地址转换

同源地址转换差不多，只不过相反操作。
**目标地址转换要定义在PREROUTING链上，否则因为报文最开始的目标是网关主机，如果不在第一时间转换目标地址，就会被视为是发给本机的报文，这样就不会转发了**

**目标地址转换的一个显著作用，就是根据客户端访问的端口，把访问报文转发至指定服务的主机。**

**1、node2主机，清空原有规则，启动httpd服务（步骤略）：**

**2、网关主机server，在PREROUTING链上做目标地址转换，使得访问server的请求，转发至node2的IP：**

```bash
[root@server ~]# iptables -t nat -A PREROUTING -p tcp --dport 80 -j DNAT --to-destination 192.168.200.1
```

3、在node1，访问server的http服务（注意server并没有开启httpd）：

```bash
[root@node1 ~]# curl 192.168.100.2
www.sensewang.cn
```

能够访问到，且就是node2主机的页面。
在再查看node2的httpd访问日志，可看到访问主机就是node1：

```bash
[root@node2 ~]# tail -1 /var/log/httpd/access_log 
192.168.100.1 - - [18/Mar/2020:22:50:40 +0800] "GET / HTTP/1.1" 200 17 "-" "curl/7.29.0"
```

#### 6.2.1  在本机上做端口映射

如果用server来作为客户端，node2是服务端。node2监听地址是8888。则node2就无法访问默认的80端口：

```bash
[root@node2 ~]# vim /etc/httpd/conf/httpd.conf 
Listen 8888
[root@node2 ~]# systemctl restart httpd
[root@server ~]# curl 192.168.200.1
curl: (7) Failed connect to 192.168.200.1:80; 拒绝连接
```

**在node2本机上做端口映射，使访问80的都转到8888端口：**

```bash
[root@node2 ~]# iptables -t nat -A PREROUTING -p tcp --dport 80 -j REDIRECT --to-port 8888
```

**server再次访问**

```bash
[root@server ~]# curl 192.168.200.1
www.sensewang.cn
```

* 额外举例：现有外网129.211.186.253、内网192.168.100.1,此服务器监听的内网web端口8080，想要外部访问：
```bash
[root@sensewang ~]# iptables -t nat -A PREROUTING -d 129.211.186.253 -p tcp --dport 8080 -j DNAT --to 192.168.100.1
#将客户端访问外网ip的8080端口请求，此服务器自动转发给本地内网192.168.100.1处理 
```



## 7、规则设置原则

**最后，再强调下规则设置的原则：**
1、同一表的同一链，规则自上而下依次匹配生效。只要匹配到，则执行对应处理动作，后续规则不再匹配。
2、原则上讲，对于同是ACCEPT处理动作的规则，匹配条件范围越大，越放在前。否则如果前N条不匹配，第N+1条匹配到了仍要放行，前面的规则匹配白白开销资源。
3、原则上讲，对于同是DROP、REJECT处理动作的规则，匹配条件范围越大，越放在前。
4、放行规则和拒绝规则相比，哪个匹配的范围越小，越放在前（范围小的可视为是做特殊处理，所以放在前面匹配）。
5、规则越少越好，多条规则如能合并，就合并。
6、匹配越频繁的规则，越写在前面。以减少该规则之前无效匹配的频率



[本文观自：CSDN，wangzhenyu177](https://blog.csdn.net/wangzhenyu177/article/details/78444788)


