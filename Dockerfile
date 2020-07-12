# base image
FROM centos:centos7.3.1611

# MAINTAINER
MAINTAINER zjb

# add epel and 163 yum
RUN yum install wget epel-release -y \
    && mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.back \
    && wget -P /etc/yum.repos.d/ http://mirrors.aliyun.com/repo/Centos-7.repo \
    && wget -P /etc/yum.repos.d/ http://mirrors.163.com/.help/CentOS7-Base-163.repo \
    && yum clean all && yum makecache

# Necessary packages
RUN yum install -y  wget gcc gcc-c++ glibc make autoconf openssl openssl-devel ntpdata crontabs

# change timzone to Asia/Shanghai
RUN cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
