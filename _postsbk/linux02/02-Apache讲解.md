---
title: 02-Apache讲解(原理篇)
date: 2020-03-09 22:25:50
banner_img: https://sense-1301203133.cos.ap-beijing.myqcloud.com/homepahe/Linux%E9%AB%98%E7%BA%A7-%E8%83%8C%E6%99%AF.jpg
index_img: http://q6vldn2n0.bkt.clouddn.com/%E9%9D%99%E5%9B%BE%20%289%29.jpg
tags:
- Linux
- Lunux高级
- Web服务
- Apache
categories:
- Linux高级
---
### 02-Apache讲解(原理篇)

-----



#### 1、Apache介绍

* 简介：Apache是一个开源、支持多平台、多模块的web服务器。

* 特点：

  * 跨平台应用，可运行windoows和大多数linux系统

  * 支持perl,php,python和java等多种网页编辑语言

  * 采用模块化设计，支持模块范围广阔

  * 运行稳定、安全性高

-----



#### 2、三种工作模式

* 作为老牌服务器，Apache仍在不断地发展，就目前来说，它一共有三种稳定的MPM（Multi-Processing Module，多进程处理模块）。

  * Prefork MPM

    * 图示：

      ![](http://q6wn0ji8x.bkt.clouddn.com/linux%E9%AB%98%E7%BA%A7/apache-Prefork-.png)

    * 简述：多进程模式、是一个比较老的模块，一个进程处理一个连接，每个进程相对独立

    * 特点：稳定、响应快、消耗大量CPU和内存、keep-alive长连接占据问题

* worker MPM

  * 图示：

    ![](http://q6wn0ji8x.bkt.clouddn.com/linux%E9%AB%98%E7%BA%A7/Apache-worker.png)

  * 简述：多进程多线程、一个进程开多个线程、每个线程处理一个连接。

  * 特点：节约系统资源，兼容性不好，稳定性不高，keep-alive占据问题

* event MPM

  * 图示：

    ![](http://q6wn0ji8x.bkt.clouddn.com/linux%E9%AB%98%E7%BA%A7/Apache-event.png)

  * worker的升级版，把服务器和连接进行分离，请求过来后进程并不处理，而是交给其他机制来处理，因此一个进程可以响应更多的请求

  * 特点：支持海量级高并发负载，消耗资源少，但对https支持的不完美

* [各通知机制详解](https://www.cnblogs.com/aspirant/p/9166944.html)

-----



#### 3、源代码安装

官方源码下载地址：https://downloads.apache.org/httpd/

Apache的两种编译方式

* 静态编译：将模块直接编译进httpd的核心中。静态编译的所有模块都会随着httpd的启动和启动。

* 动态编译：将模块编译好，但不编译到httpd的核心中。要启动动态编译的模块，需要在httpd的配置文件中使用LoadModule指令加载。
* 例如：安装httpd，指定工作目录并开启动态加载模块、重写、CGI接口功能

```bash
[root@www httpd-2.2.17]# ./configure --prefix=/usr/local/httpd --enable-so --enable-rewrite --enable-cgi  &&  make  &&make install
```

-----



#### 4、Apache日志格式

**标准日志格式：192.168.115.5 - - [01/Apr/2018:10:37:19 +0800] "GET / HTTP/1.1" 200 45**

1. 远程主机IP：表明访问网站的IP
2. 空白(E-mail)：为了避免用户的邮箱被垃圾邮件骚扰，第二项就用“-”取代了
3. 空白(登录名)：用于记录浏览者进行身份验证时提供的名字
4. 请求时间：用方括号包围，而且采用“公用日志格式”或者“标准英文格式”
5. 方法+资源+协议：服务器收到的是一个什么样的请求
6. 状态码：请求是否成功，或者遇到了什么样的错误
7. 发送字节数：表示发送给客户端的总字节数

-----



#### 5、配置文件详解

配置文件路径，为httpd根目录下的conf中的httpd.conf，其中conf目录下的extra为其子配置文件

  * `ServerRoot `：httpd的根目录

  * `Listen`：监听地址及IP

  * `LoadModule ***.so`：启动时加载的模块

  * `<IfModule unixd_module></IfModule>`配置段：用于配置启动的用户和组

  * `ServerAdmin`：配置管理员邮箱

  * `<Directory Dir></Directory>`： 配置行为对Dir目录的限制

    ```bash
    AllowOverride none		#表示禁止用户对目录配置文件(.htaccess进行修改)重载，普通站点不建议开启
    Require all denied		#禁止所有请求
    Options中Indexes表示当网页不存在的时候允许索引显示目录中的文件，FollowSymLinks是否允许访问符号链接文件
    Order对页面的访问控制顺序后面的一项是默认选项，如allow，deny则默认是deny
    Allowfromall表示允许所有的用户
    ```

* `DocumentRoot`：apache的默认web站点目录路径，结尾不要添加斜线，可以添加`<Directory></Directory>`配置段进行管理

* `DirectoryIndex`：指定所要访问的主页的默认主页名字

* `ErrorLog`：错误日志存放的位置

* `LogLevel `：Apache日志的级别

* `LogFormat`：定义日志格式，后面用一个变量接收

* `CustomLog `：访问日志的存放路径

* `Include`：包含的其他配置文件

-----



#### 6、三种工作模式配置

* 查看当前工作模式，此版本默认为worker

  ```bash
  [root@http ~]# apachectl -V |grep MPM
  Server MPM:     worker
  ```

* 配置时可指定工作模式

  ```bash
  ./configure --prefix=/usr/local/httpd --with-mpm=event
  ```

* 各工作模式配置文件详解：无论哪种工作模式，配置文件都在http根目录下的conf/extra/httpd-mpm.conf中

  * `Prefork MPM`

    ```bash
    <IfModule mpm_prefork_module>		
    StartServers 5				#数量的服务器进程开始
    MinSpareServers 5			#最小数量的服务器进程,保存备用
    MaxSpareServers 10			#最大数量的服务器进程,保存备用
    MaxRequestWorkers 250		#最大数量的服务器进程允许开始
    MaxConnectionsPerChild 0	#最大连接数的一个服务器进程服务
    </IfModule> 
    ```

  * `worker MPM `

    ```bash
    <IfModule mpm_worker_module>
    StartServers 3				#初始数量的服务器进程开始
    MinSpareThreads 75			#最小数量的工作线程,保存备用
    MaxSpareThreads 250 		#最大数量的工作线程,保存备用
    ThreadsPerChild 25			#固定数量的工作线程在每个服务器进程
    MaxRequestWorkers 400		#最大数量的工作线程
    MaxConnectionsPerChild 0	#最大连接数的一个服务器进程服务
    </IfModule>
    ```

  * `event MPM`

    ```bash
    <IfModule mpm_event_module>
    StartServers 3				#初始数量的服务器进程开始
    MinSpareThreads 75			#最小数量的工作线程,保存备用
    MaxSpareThreads 250			#最大数量的工作线程,保存备用
    ThreadsPerChild 25			#固定数量的工作线程在每个服务器进程
    MaxRequestWorkers 400		#最大数量的工作线程
    MaxConnectionsPerChild 0	#最大连接数的一个服务器进程服务
    </IfModule> 
    ```

-----



#### 7、日志分割与合并

* 合并
  * 概述：用来合并多个日志文件到一个中，便于管理
  * `sort  -k 4 -o log_all 日志1 日志2`
* 分割
  * 概述：把信息量大的日志，分割成单个文件，便于日志分析
  * 方式1：使用Apache自带的日志轮询程序：rotatelogs
  * 方式2：第三方工具：cronolog
  * 方式3：利用定时任务和shell脚本

-----



#### 8、keep-alive(长链接)

* 简介：KeepAlive值是个布尔值，有两个值On和Off，简单来说，当值为On的时候，用户发起HTTP请求后，Apache不会立刻关闭这个连接，当还有用户发起HTTP请求时，还会使用这个连接。值为OFF时，用户发起HTTP请求后，Apache会立刻关闭这个连接，缺点就是每次访问都要执行一次TCP握手，增加了CPU的开销。
* 特点：
  * 对于客户端：提高了客户端的响应时间
  * 对于服务器：降低了TCP连接时的资源消耗

-----



#### 9、网页压缩

* 概述：使用 Gzip 压缩算法来对 Apache 服务器发布的网页内容进行压缩后再传输到客户端浏览器

* 特点：加快网页加载速度，降低网络传输带宽，有利于搜索引擎的抓取

* 两种压缩方式对比

  ![mark](http://q6wn0ji8x.bkt.clouddn.com/Linux高级/20200314/DknsmHyxjwLv.png?imageslim)

#### 10、网页缓存时间

* 概述：通过 mod_expires 模块配置 Apache，使网页能在客户端浏览器缓存一段时间，以避免重复请求，类似于keep-alive
* 特点：降低客户端的访问频率和次数，减少不必要的流量损失

-----



#### 11、隐藏版本号

* 因为各版本都有各自的缺点，防止他人通过版本恶意袭击网站及泄露信息，需要隐藏版本号

-----



#### 12、防盗链

* 防盗链就是防止别人盗用服务器中的图片、文件、视频等相关资源

-----



#### 13、ab压力测试

* Apache 附带了压力测试工具 ab，非常容易使用，并且完全可以模拟各种条件对 Web 服务器发起测试请求，在进行性能调整优化过程中，可用 ab 压力测试工具进行优化效果的测试。

-----



#### 14、日志分析工具

* apachetop工具：查看服务器的实时运行情况，比如哪些 URL 的访问量最大，服务器每秒的请求数，等等。apachetop 就是这样一个工具， 能够让你实时的监测 apache 服务器的运行状况。

* awstats日志分析系统
  * 简介：AWStats是使用Perl语言开发的一款开源日志分析系统，它不仅可用来分析Apache网站服务器的访问日志，也可以用来分析Samba、Vsftpd、IIS等服务的日志信息。结合crond等计划任务服务，可以对不断增长的日志内容定期进行分析。
  * 能力：
    - 访问量、访问次数、独特访客人数;
    - 访问时间和上次访问;
    - 每周的高峰时间(页数,点击率,每小时和一周的千字节);
    - 域名/国家的主机访客(页数,点击率,字节,269域名/国家检测, geoip 检测);
    - 主机名单,最近访问和未解析的 IP 地址名单;
    - 访问者看过的进出页面,档案类型;
    - 网站压缩统计表(mod_gzip 或者 mod_deflate);
    - 使用的操作系统 (每个操作系统的页数,点击率 ,字节, 35 OS detected),使用的浏览器;
    - 搜索引擎，利用关键词检索找到你的地址;
    - HTTP 协议错误(最近查阅没有找到的页面);
    - 其他基于 URL 的个性报导,链接参数, 涉及综合行销领域目的;
    - 网站被加入"最喜爱的书签".次数;
    - 浏览器的支持比例: Java, Flash, RealG2 reader, Quicktime reader, WMA reader, PDF reader;
    - 负载平衡服务器比率集群报告;

-----



#### 15、访问控制

* 为apache服务提供的页面设置客户端访问权限，为某个组或者某个用户加密访问；
* 进行IP及网段限制

-----



#### 16、虚拟主机

* 在同一台服务器实现部署多个网站站点，节省资源；

* 多种方式：

  1. 不同IP，不同域名，相同端口；基于IP的虚拟主机

  2. 相同IP，相同域名，不同端口；基于端口的虚拟主机

  3. 相同IP，相同端口，不同域名；基于域名的虚拟主机
