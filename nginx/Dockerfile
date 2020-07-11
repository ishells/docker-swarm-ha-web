FROM centos:v1
MAINTAINER zjb
RUN yum -y install pcre-devel openssl-devel net-tools gcc gcc-c++ zlib zlib-devel \
    make openssl
ADD nginx-1.12.2.tar.gz /tmp/
RUN cd /tmp/nginx-1.12.2 \
    && ./configure --prefix=/usr/local/nginx \
     --with-http_ssl_module \
     --with-http_gzip_static_module \
     --with-http_realip_module \
    && make && make install
RUN mkdir -p /etc/nginx/ \
    && mkdir /var/log/nginx/ \
    && touch /var/log/nginx/error.log \
    && touch /var/log/nginx/access.log

ADD nginx.conf /usr/local/nginx/conf/nginx.conf
ADD mime.types /etc/nginx/mime.types

RUN mkdir -p /usr/local/nginx/logs \
    && mkdir -p /usr/local/nginx/conf/vhosts \
    && groupadd -g 1001 nginx \
    && useradd -g 1001 -u 1001 -s /sbin/nologin -M nginx
RUN cat /usr/share/zoneinfo/Asia/Shanghai > /etc/localtime

EXPOSE 80
EXPOSE 443
CMD ["/usr/local/nginx/sbin/nginx", "-g", "daemon off;"]
