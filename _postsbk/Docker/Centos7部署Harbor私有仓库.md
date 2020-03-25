---
title: Docker篇-部署Harbor私有仓库
date: 2020-03-09 15:20:45
banner_img: https://sense-1301203133.cos.ap-beijing.myqcloud.com/homepahe/Docker-%E8%83%8C%E6%99%AF.png
index_img: http://q6vldn2n0.bkt.clouddn.com/%E9%9D%99%E5%9B%BE%20%287%29.jpg
tags:
- Docker
- Linux
categories:
- Docker
---

## Docker篇-部署Harbor私有仓库



### Harbor介绍

* **简介：**Harbor是一个由VMware公司开源的一个企业级私有registry。是Docker镜像存储的“港湾”，作为企业级私有registry，其性能和安全性是不容置疑的，其中包含用户管理，访问控制，活动日志审计等。
* **logo**：<img src="http://q6wn0ji8x.bkt.clouddn.com/VM-Harbor-logo.jpg" width=50%>
* **特点**：
  1. 基于角色的访问控制：可以创建管理用户，对其赋予应有权限。
  2. 镜像复制：镜像可以在多个Registry实例中复制（同步）
  3. 图形化用户界面：用户可以通过浏览器进行访问操作
  4. 审计管理：所有针对镜像仓库的操作都可以被记录追溯，用于审计管理。
  5. 支持多种语言，包括中文
  6. RESTful API： 提供给管理员对于Harbor更多的操控, 使得与其它管理软件集成变得更容易。
  7. 安全性：可以对镜像进行校验码匹配，及漏洞扫描

----

### harbor部署

* **系统环境：**

  | 操作系统  | 主机名              | IP            | 已装软件          |
  | --------- | ------------------- | ------------- | ----------------- |
  | Centos7.4 | harbor.sensewang.cn | 192.168.100.1 | docker-18.06.0-ce |
  | Centos7.4 | node.sensewang.cn   | 192.168.100.2 | docker-18.06.0-ce |

* **修改hosts、主机名、关闭防火墙、selinux、ntp时间同步，过程免**

* **所需源码包下载**

  1. harbor源码包下载：https://github.com/goharbor/harbor/releases/download/v1.9.4/harbor-offline-installer-v1.9.4.tgz
  2. docker-compose下载：https://github.com/docker/compose/releases/download/1.23.1/docker-compose-Linux-x86_64

* **Harbor节点：安装docker-compose**

  ```bash
  [root@harbor ~]# chmod +x docker-compose 
  [root@harbor ~]# mv docker-compose /usr/local/bin/
  [root@harbor ~]# docker-compose version
  docker-compose version 1.23.1, build b02f1306
  docker-py version: 3.5.0
  CPython version: 3.6.7
  OpenSSL version: OpenSSL 1.1.0f  25 May 2017
  ```

* **harbor节点：生成https自签证书, 因为docker是采用https协议通信**

  ```bash
  [root@harbor cret]# mkdir /etc/cret
  [root@harbor cret]# cd /etc/cret/
  [root@harbor cret]# openssl req -newkey rsa:4096 -sha256 -keyout ca.key -x509 -days 365 -out ca.crt
  [root@harbor cret]# openssl req -nodes -newkey rsa:4096 -sha256 -keyout harbor.sensewang.cn.key -out harbor.sensewang.cn.csr
  [root@harbor cret]# openssl x509 -req -days 365 -in harbor.sensewang.cn.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out harbor.sensewang.cn.crt
  [root@harbor cret]# ls
  ca.crt  ca.key  ca.srl  harbor.sensewang.cn.crt  harbor.sensewang.cn.csr  harbor.sensewang.cn.key
  ```

* **安装并配置harbor**

  * 配置文件解释，新版本中有的不包含：

     > hostname：harbor服务器的主机名，不能为localhost
     >
     > ui_url_protocol：指定web页面通信协议
     >
     > Email settings：管理员邮箱设置
     >
     > harbor_admin_password：管理员admin的密码
     >
     > auth_mode：用户认证模式，默认是db_auth,也可以使用ldap验证。
     >
     > db_password：使用db需要指定连接数据库的密码
     >
     > self_registration：是否允许自行注册用户，默认是on。
     >
     > max_job_workers：最大工作数

  * harbor节点：安装并配置harbor

     ```bash
     # 安装并配置harbor
     [root@harbor ~]# tar xf harbor-offline-installer-v1.9.4.tgz -C /usr/local/
     [root@harbor ~]# cd /usr/local/harbor/
     [root@harbor harbor]# vim harbor.yml 
     # 配置文件修改如下
     hostname: harbor.sensewang.cn
     https:
       port: 443
       certificate: /etc/cret/harbor.sensewang.cn.crt
       private_key:  /etc/cret/harbor.sensewang.cn.key
     ```

  * harbor节点：运行install.sh

     ```bash
     [root@harbor harbor]# ./install.sh 
     ………………
     
     ✔ ----Harbor has been installed and started successfully.----
     
     Now you should be able to visit the admin portal at https://harbor.sensewang.cn. 
     For more details, please visit https://github.com/goharbor/harbor .
     ………………
     ```

  * web页面操作，新建一个项目：https://harbor.sensewang.cn

     <img src="http://q6wn0ji8x.bkt.clouddn.com/docker/Harbor-login.png" width=100%>

     <img src="http://q6wn0ji8x.bkt.clouddn.com/docker/harbor-newProject.png" width=100%>

     <img src="http://q6wn0ji8x.bkt.clouddn.com/docker/harbor-newProject.png" width=100%>

  * node节点：配置信任harbor服务器

     ```bash
     [root@node ~]# vim /etc/docker/daemon.json 
     {
              "registry-mirrors":["https://ung2thfc.mirror.aliyuncs.com"],
              "insecure-registries":["https://harbor.sensewang.cn"]
     }
     [root@node ~]# systemctl daemon-reload
     [root@node ~]# systemctl restart docker
     ```

  

* **客户端推送镜像验证**

  * node节点：登录、这里使用的是admin用户，可自行创建

     ```bash
     [root@node ~]# docker login harbor.sensewang.cn
     Username: admin
     Password: 
     WARNING! Your password will be stored unencrypted in /root/.docker/config.json.
     Configure a credential helper to remove this warning. See
     https://docs.docker.com/engine/reference/commandline/login/#credentials-store
     
     Login Succeeded
     ```

  * 推送镜像

     ```bash
     [root@node ~]# docker pull centos	#从docker上先下载一个镜像
     [root@node ~]# docker tag centos harbor.sensewang.cn/sense/mycentos:v1	#打上新建项目的标签
     [root@node ~]# docker push harbor.sensewang.cn/sense/mycentos:v1	#推送
     The push refers to repository [harbor.sensewang.cn/sense/mycentos]
     0683de282177: Pushed 
     v1: digest: sha256:9e0c275e0bcb495773b10a18e499985d782810e47b4fce076422acb4bc3da3dd size: 529
     ```

  * 浏览器登录查看

     <img src="http://q6wn0ji8x.bkt.clouddn.com/docker/harbor-push-success.png" width=100%>

* **harbor服务器上的日志：**

```bash
[root@harbor /]# cd /var/log/harbor/
[root@harbor harbor]# ls
core.log  jobservice.log  portal.log  postgresql.log  proxy.log  redis.log  registryctl.log  registry.log
```

* **开启、关闭harbor**

```bash
[root@harbor ~]# docker-compose -f /usr/local/harbor/docker-compose.yml down	#通过docker-compose关闭
[root@harbor ~]# docker-compose -f /usr/local/harbor/docker-compose.yml up -d	#开启，并后台运行
```




