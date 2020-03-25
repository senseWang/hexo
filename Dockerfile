FROM centos:7.4.1708
LABEL author=sense email=sense_s_wang@163.com site=http://www.sensewang.cn
WORKDIR /opt/hexo
COPY nodejs-10.19.0-1nodesource.x86_64.rpm /usr/src/
RUN yum localinstall -y /usr/src/nodejs-10.19.0-1nodesource.x86_64.rpm  \
&& yum -y install git && npm install hexo-cli -g  && hexo init sense && cd sense && npm install
WORKDIR sense
EXPOSE 80
ENTRYPOINT ["hexo","server","-p","80"]
