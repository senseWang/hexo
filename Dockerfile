FROM centos:7.4.1708
LABEL author=sense email=sense_s_wang@163.com site=http://www.sensewang.cn
WORKDIR /opt/hexo
RUN curl --silent --location https://rpm.nodesource.com/setup_10.x | bash -  \
&& yum -y install nodejs && npm install hexo-cli -g  && hexo init sense && cd sense && npm install
WORKDIR sense
EXPOSE 80
ENTRYPOINT ["hexo","server","-p","80"]
