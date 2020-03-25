---
title: 03-Apache案例
date: 2020-03-14 23:00:50
banner_img: https://sense-1301203133.cos.ap-beijing.myqcloud.com/homepahe/Linux%E9%AB%98%E7%BA%A7-%E8%83%8C%E6%99%AF.jpg
index_img: https://sense-1301203133.cos.ap-beijing.myqcloud.com/index-page/%E9%9D%99%E5%9B%BE%20%284%29.jpg
tags:
- Linux
- Lunux高级
- Web服务
- Apache
categories:
- Linux高级
---

### 03-Apache案例

-----



#### 案例环境：

|   系统    |       IP        |     角色     | 性能    |
| :-------: | :-------------: | :----------: | ------- |
| CentOS7.4 |  192.168.100.1  | apache服务器 | 4G，4核 |
| Windows10 | 192.168.100.254 |    客户端    | 4G，4核 |



#### 1、安装httpd

官网下载地址：https://downloads.apache.org/httpd/

1. 配置编译安装

   ```bash
   [root@sensewang ~]# tar xf httpd-2.4.25.tar.gz -C /usr/src/
   [root@sensewang ~]# cd /usr/src/httpd-2.4.25/
   [root@sensewang httpd-2.4.25]# yum -y install apr apr-devel apr-util apr-util-devel pcre-devel zlib-devel
   [root@sensewang httpd-2.4.25]# ./configure --prefix=/usr/local/httpd --enable-cgi --enable-rewrite --enable-so  --enable-deflate --enable-expires && make && make install
   ```

   配置参数详解：

   * `--enable-so`：开启Apache动态安装共享模块
   * `--enable-cgi`：开启cgi网络接口
   * `--enable-rewrite`：提供基于URL规则的重写功能
   * `--enable-deflate`：提供对内容的压缩传输支持(调优)
   * `--enable-expires`：提供在客户端缓存的设置(调优)
   * `--with-mpm=worker`：指定Apache工作模式为worker

2. 优化httpd环境

   ```bash
   [root@sensewang httpd-2.4.25]# cd
   [root@sensewang ~]# ln -s /usr/local/httpd/bin/* /usr/local/bin/ 
   [root@sensewang ~]# cp /usr/local/httpd/bin/apachectl /etc/init.d/httpd
   ```

3. 访问测试

   ![mark](https://sense-1301203133.cos.ap-beijing.myqcloud.com/sense-linux/m7ItwDAnvc3T.png)

-----



#### 2、保持长链接(Keep-alive)、网页压缩、页面缓存时间、隐藏版本号

1. **保持长链接：**

   ```bash
   [root@sensewang ~]# vim /usr/local/httpd/conf/httpd.conf 
   492 Include conf/extra/httpd-default.conf		#去掉#号，表示启用此配置文件
   [root@sensewang ~]# vim /usr/local/httpd/conf/extra/httpd-default.conf 		#修改如下
   16 KeepAlive On					#开启长链接
   23 MaxKeepAliveRequests 100		#最大保持长链接数
   29 KeepAliveTimeout 5			#长链接最大保持时间
   [root@sensewang ~]# /etc/init.d/httpd restart
   ```

   **访问测试，使用fiddler抓包工具：**

   ![mark](https://sense-1301203133.cos.ap-beijing.myqcloud.com/sense-linux/gNxgLSg7WoqH.png)

   -----

   

2. **网页压缩、默认已开启：**

   ![mark](https://sense-1301203133.cos.ap-beijing.myqcloud.com/sense-linux/gLNaqYK95W6x.png)

   -----

   

3. **页面缓存时间**

   **已经编译好的httpd，如何添加deflate模块：**

   ```bash
   [root@sensewang metadata]# cd /usr/src/httpd-2.4.25/modules/metadata/	#先进入mod_deflate.c文件所在目录
   [root@sensewang metadata]# apxs -i -c -a mod_expires.c     #利用apxs文件编译目标模块
   [root@sensewang metadata]# /usr/local/httpd/bin/apachectl -D DUMP_MODULES |grep expires					#重启httpd并验证模块是否添加
   AH00558: httpd: Could not reliably determine the server's fully qualified domain name, using sensewang.com. Set the 'ServerName' directive globally to suppress this message
   expires_module (shared)
   ```

   **添加完成之后，修改配置文件：**

   ```bash
   [root@sensewang metadata]# vim /usr/local/httpd/conf/httpd.conf
   #添加如下内容
   <IfModule mod_expires.c>
       ExpiresActive On
       ExpiresDefault "access plus 60 seconds"
   </IfModule>
   [root@sensewang metadata]# /etc/init.d/httpd restart		#重启
   ```

   **访问测试：**

   ![mark](https://sense-1301203133.cos.ap-beijing.myqcloud.com/sense-linux/MpWGXUPfE6ly.png)

   -----

   

4. **隐藏版本号**

   ```bash
   [root@sensewang metadata]# vim /usr/local/httpd/conf/httpd.conf
   #页尾添加
   ServerTokens Prod		##显示最少的信息，默认是Full显示完整信息
   ServerSignature Off		##生成页面的页脚
   [root@sensewang metadata]# /etc/init.d/httpd restart
   ```

   访问测试：

   ![mark](https://sense-1301203133.cos.ap-beijing.myqcloud.com/sense-linux/6X0VW7PoUt2H.png)

-----



#### 3、日志分割

* **利用 apache 自带的日志轮循程序 rotatelogs日志分割**

  ```bash
  [root@sensewang logs]# vim /usr/local/httpd/conf/httpd.conf 	#自定义log
  CustomLog "|/usr/local/httpd/bin/rotatelogs -l /usr/local/httpd/logs/access_%Y%m%d%H%M%S.log  10" combined			##10秒切割一次日志文件    -l选项是小写的L表示local time（本地时间）
  [root@sensewang logs]# /etc/init.d/httpd restart
  [root@sensewang logs]# ls			#有日志后，十秒分割一次
  access_20200314212810.log  access_20200314213130.log  access_20200314213240.log  access_log  error_log  httpd.pid
  ```

* **利用一个发展已经比较成熟的日志轮循工具 cronolog**

  1. 安装cronolog

     ```bash
     [root@sensewang ~]# tar xf cronolog-1.6.2.tar.gz -C /usr/src/
     [root@sensewang ~]# cd /usr/src/cronolog-1.6.2/
     [root@sensewang cronolog-1.6.2]# ./configure && make && make install
     [root@sensewang cronolog-1.6.2]# which cronolog
     /usr/local/sbin/cronolog
     ```

  2. 修改httpd配置文件

     ```bash
     [root@sensewang logs]# vim /usr/local/httpd/conf/httpd.conf 	#自定义log
     CustomLog "|/usr/local/sbin/cronolog /usr/local/httpd/logs/cronolog_access_%Y%m%d.log"         combined
     [root@sensewang logs]# /etc/init.d/httpd restart
     [root@sensewang logs]# ls
     access_log  cronolog_access_20200314.log  error_log  httpd.pid
     ```

------



#### 4、防盗链

|   系统    |      IP       |            角色            | 性能    | 已装软件            |
| :-------: | :-----------: | :------------------------: | ------- | ------------------- |
| CentOS7.4 | 192.168.100.1 | 阿里巴巴公司，apache服务器 | 4G，4核 | httpd-2.4.25.tar.gz |
| CentOS7.4 | 192.168.100.3 | 阿米巴巴公司，apache服务器 | 4G，2核 | httpd-2.4.25.tar.gz |

**1、两个公司同时卖一件衣服，网站上放着图片**

阿里巴巴：

![mark](https://sense-1301203133.cos.ap-beijing.myqcloud.com/sense-linux/OHCebpeKT3e3.png)

阿米巴巴：

![mark](https://sense-1301203133.cos.ap-beijing.myqcloud.com/sense-linux/pPpYzNbVkRbn.png)

**2、我们来查看他们的源码**

阿里巴巴：

```html
<h1>欢迎来到阿里巴巴</h1>
<img src="sense.jpg" />
```

阿米巴巴：

```html
<h1>欢迎来到阿米巴巴</h1>
<img src="http://192.168.100.1/sense.jpg">
```

***结论：阿米巴巴公司使用阿里巴巴公司的图片进行销售，消耗阿里巴巴公司的网络、硬盘、系统资源***

**3、阿里巴巴公司设立防盗链，让阿米巴巴公司歇菜**

```bash
[root@sensewang ~]# vim /usr/local/httpd/conf/httpd.conf
LoadModule rewrite_module modules/mod_rewrite.so		#去除注释，开启重写功能
[root@sensewang ~]# apachectl -M | grep rewrite
rewrite_module (shared)							#已共享、开启
[root@sensewang htdocs]# vim /usr/local/httpd/conf/httpd.conf
RewriteEngine On
RewriteCond %{HTTP_REFERER} !http://sensewang\.com/.*$ [NC]
RewriteCond %{HTTP_REFERER} !http://sensewang\.com$ [NC]
RewriteCond %{HTTP_REFERER} !http://192\.168\.100\.1/.*$ [NC]
RewriteCond %{HTTP_REFERER} !http://192\.168\.100\.1$ [NC]
RewriteRule .*\.(gif|jpg|swf)$ http://sensewang.com/dao/wang.png [R,NC,L]
[root@sensewang htdocs]# ls /usr/local/httpd/htdocs/dao/
wang.png
[root@sensewang htdocs]# /etc/init.d/httpd restart
```

配置项解释：

* `RewriteEngine On ` 						      	#启用重写
* `RewriteCond %{HTTP_REFERER} !http://sensewang\.com/.*$ [NC]`           #设置允许访问的来源
* `RewriteRule .*\.(gif|jpg|swf)$ http://sensewang.com/dao/wang.png [R,NC,L] ` 		#将不满足`referer`条件的访问重定向至wang.png。nolink.png位于允许“盗链”的目录about中，要相当注意，跳转的图片不能为jpg，因为已经被禁了，不然，警告信息和图片将无法在对方网站上显示。
* `[ NC]`指的是不区分大小写,`[R]`强制重定向`redirect`
* 字母`L`表示如果能匹配本条规则，那么本条规则是最后一条(Last)，忽略之后的规则。

**查看验证：**

阿里巴巴

![mark](https://sense-1301203133.cos.ap-beijing.myqcloud.com/sense-linux/dwtPmXthXil5.png)

阿米巴巴

![mark](https://sense-1301203133.cos.ap-beijing.myqcloud.com/sense-linux/DHwImPBI0HUN.png)

-----



#### 5、访问限制

* 客户机地址限制

  * 先允许后拒绝，默认拒绝所有：Order allow,deny
  * 先拒绝后允许，默认允许所有：Order deny,allow

  ```bash
  [root@sensewang ~]# vim /usr/local/httpd/conf/httpd.conf
  资源存放路径配置项添加限制
  <Directory "/usr/local/httpd/htdocs">
      Order deny,allow
      Deny from 192.168.100.1       #先拒绝后允许，拒绝本机，允许所有
      Require all granted
  </Directory>
  [root@sensewang ~]# /etc/init.d/httpd restart
  [root@sensewang ~]# curl 192.168.100.1				#本机已无法访问
  <!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML 2.0//EN">
  <html><head>
  <title>403 Forbidden</title>
  </head><body>
  <h1>Forbidden</h1>
  <p>You don't have permission to access /
  on this server.<br />
  </p>
  </body></html>
  ```

  win10访问测试：

  ![](https://sense-1301203133.cos.ap-beijing.myqcloud.com/sense-linux/20200315163624.png)

* 用户授权限制

  ```bash
  [root@sensewang ~]# htpasswd -c /usr/local/httpd/conf/.awspad sense		#添加授权的用户名密码
  New password:wss123
  Re-type new password: wss123
  Adding password for user sense
  [root@sensewang ~]# vim /usr/local/httpd/conf/httpd.conf
  资源存放路径配置项添加限制
  <Directory "/usr/local/httpd/htdocs">
      Options Indexes FollowSymLinks
      AllowOverride None
      AuthName "www.sensewang.cn"			#说明信息
      AuthType Basic						#验证方法
      AuthUserFile /usr/local/httpd/conf/.awspad		#存放有效用户密码的文件
      require valid-user					#只允许有效用户
  </Directory>
  [root@sensewang ~]# /etc/init.d/httpd restart
  ```

  登录验证：

  ![](https://sense-1301203133.cos.ap-beijing.myqcloud.com/sense-linux/20200315164257.png)

-----



#### 6、虚拟web主机

* **基于域名的虚拟web主机**

  1. 创建测试页面

     ```bash
     [root@sensewang ~]# mkdir /usr/local/httpd/htdocs/wang
     [root@sensewang ~]# echo "<h1>wang</h1>" > /usr/local/httpd/htdocs/wang/index.html
     [root@sensewang ~]# mkdir /usr/local/httpd/htdocs/sense
     [root@sensewang ~]# echo "<h1>sense</h1>" > /usr/local/httpd/htdocs/sense/index.html
     ```

  2. 修改配置文件

     ```bash
     [root@sensewang ~]# vim /usr/local/httpd/conf/httpd.conf
     # Virtual hosts			
     Include conf/extra/httpd-vhosts.conf	#去除注释，使此配置文件生效
     [root@sensewang ~]# vim /usr/local/httpd/conf/extra/httpd-vhosts.conf      #修改虚拟主机配置文件
     <VirtualHost 192.168.100.1:80>			#同一ip、端口，不同域名
         DocumentRoot "/usr/local/httpd/htdocs/sense/"	#对应的资源
         ServerName www.sense.com			#域名
         ErrorLog "sense.example.com-error_log"	
         CustomLog "sense.example.com-access_log" common
     </VirtualHost>
     
     <VirtualHost 192.168.100.1:80>			#再添加一个基于域名的
         DocumentRoot "/usr/local/httpd/htdocs/wang/"
         ServerName www.wang.com
         ErrorLog "logs/wang.example.com-error_log"
         CustomLog "logs/wang.example.com-access_log" common
     </VirtualHost>
     ```

  3. 访问测试

     ```bash
     [root@sensewang ~]# curl www.wang.com
     <h1>wang</h1>
     [root@sensewang ~]# curl www.sense.com
     <h1>sense</h1>
     ```

* **基于ip的虚拟web主机**

  1. 修改虚拟主机配置文件

     ```bash
     [root@sensewang ~]# vim /usr/local/httpd/conf/extra/httpd-vhosts.conf 
     <VirtualHost 192.168.100.22:80>		#相同ip、端口，不同IP
         DocumentRoot "/usr/local/httpd/htdocs/sense/"
         ServerName www.sense.com
         ErrorLog "sense.example.com-error_log"
         CustomLog "sense.example.com-access_log" common
     </VirtualHost>
     <VirtualHost 192.168.100.33:80>
         DocumentRoot "/usr/local/httpd/htdocs/wang/"
         ServerName www.wang.com
         ErrorLog "logs/wang.example.com-error_log"
         CustomLog "logs/wang.example.com-access_log" common
     </VirtualHost>
     ```

  2. 添加网卡子接口

     ```bash
     [root@sensewang ~]# ifconfig ens33:0 192.168.100.22/24 
     [root@sensewang ~]# ifconfig ens33:1 192.168.100.33/24
     [root@sensewang ~]# ip a
     …………
     2: ens33: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP qlen 1000
         link/ether 00:0c:29:0a:38:04 brd ff:ff:ff:ff:ff:ff
         inet 192.168.100.1/24 brd 192.168.100.255 scope global ens33
            valid_lft forever preferred_lft forever
         inet 192.168.100.22/24 brd 192.168.100.255 scope global secondary ens33:0
            valid_lft forever preferred_lft forever
         inet 192.168.100.33/24 brd 192.168.100.255 scope global secondary ens33:1
            valid_lft forever preferred_lft forever
     …………
     ```

  3. 访问测试

     ```bash
     [root@sensewang ~]# /etc/init.d/httpd restart
     [root@sensewang ~]# curl 192.168.100.33
     <h1>wang</h1>
     [root@sensewang ~]# curl 192.168.100.22
     <h1>sense</h1>
     ```

* **基于端口的虚拟web主机**

  1. 修改虚拟主机配置文件

     ```bash
     [root@sensewang ~]# vim /usr/local/httpd/conf/extra/httpd-vhosts.conf 
     <VirtualHost 192.168.100.1:6666>		#相同IP、域名，不同端口
         DocumentRoot "/usr/local/httpd/htdocs/sense/"
         ServerName www.sense.com
         ErrorLog "sense.example.com-error_log"
         CustomLog "sense.example.com-access_log" common
     </VirtualHost>
     <VirtualHost 192.168.100.1:8888>
         DocumentRoot "/usr/local/httpd/htdocs/wang/"
         ServerName www.sense.com
         ErrorLog "logs/wang.example.com-error_log"
         CustomLog "logs/wang.example.com-access_log" common
     </VirtualHost>
     ```

  2. 修改主配置文件，使其监听以上两个端口

     ```bash
     [root@sensewang ~]# vim /usr/local/httpd/conf/httpd.conf
     Listen 192.168.100.1:6666
     Listen 192.168.100.1:8888
     [root@sensewang ~]# /etc/init.d/httpd restart
     [root@sensewang ~]# netstat -anput|grep httpd
     tcp        0      0 192.168.100.1:8888      0.0.0.0:*               LISTEN      18489/httpd         
     tcp        0      0 192.168.100.1:6666      0.0.0.0:*               LISTEN      18489/httpd         
     tcp6       0      0 :::80                   :::*                    LISTEN      18489/httpd
     ```

  3. 访问测试

     ```bash
     [root@sensewang ~]# curl 192.168.100.1:8888
     <h1>wang</h1>
     [root@sensewang ~]# curl 192.168.100.1:6666
     <h1>sense</h1>
     ```

     

  


