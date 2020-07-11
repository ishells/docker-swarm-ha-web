#### docker-swarm-ha-web
> 一个基于docker swarm的简单高可用web集群

#### 一、简单高可用web集群搭建思路：
>
> 1、3个master节点，2个work节点，2个负载均衡节点，数据库集群（没有尝试搭建数据库集群）
>
> 2、如上结构，在manager1节点创建私人仓库registry，镜像持久化存储 manager1节点初始化集群，其他节点加入集群，将lnmp的镜像push到私人仓库，然后各个节点pull各种镜像，在master节点上创建某一种服务将会引导工作节点创建对应的容器，容器也会平均分配到每一个work节点。
>
> 3、集群工作节点的web服务自身就具有高可用性，访问不同节点的ip都能访问到相同的服务，副本数量可控，manager leader节点宕机会推选出新的leader，然后在添加2个keeplived + nginx 负载均衡实现VIP访问web服务，负载均衡调度其高可用，master节点宕机可平规过渡VIP.


#### 二、几个重要的配置文件
> 1、目录结构
>> ![image.png](https://www.ishells.cn/upload/2020/07/image-3624eea66de94902896ca50a0db40a4b.png)
> 

#### 三、搭建步骤

3.1 集群拓扑
表3-1 docker高可用集群系统环境
节点名称	IP	操作系统
manager1	192.168.52.200	CentOS7
manager2	192.168.52.201	CentOS7
manager3	192.168.52.202	CentOS7
node1	192.168.52.210	CentOS7
node2	192.168.52.220	CentOS7
lb-master	192.168.52.230	CentOS7
lb-slave	192.168.52.240	CentOS7

图3-1 集群拓扑
3.2 二进制安装docker
（ 可使用yum 安装docker ）
3.2.1  manager1节点
 
图3-1 manager1解压二进制包
 
图3-2 设置systemed管理
 
图3-3 启动并开机自启
3.2.2 manager2节点 
 
图3-4 manager2解压安装包
 
图3-5 设置systemed管理
 
图3-6 启动并开机自启
3.2.3 manager3节点
 
图3-7 manager3节点解压二进制包
 
图3-8 设置systemd管理并开机自启
3.2.4 node1节点
 
图3-9 node1节点解压
 
图3-10 设置systemd管理
3.3 搭建私有镜像仓库：
① docker pull registry
 
图3-11 拉取registry镜像仓库
② 启动镜像容器并挂载本地目录
  默认情况下，会将仓库存放于容器内的/var/lib/registry目录下，这样如果容器被删除，则存放于容器中的镜像也会丢失，所以我们一般情况下会指定本地一个目录
 
图3-12 创建容器并挂载目录到本地
3.4 集群初始化
① 获取worker节点加入的token
 
图3-13 获取worker节点的token
② 获取manager节点加入的token
 
图3-14 获取manager的token
③ manager节点加入
 
图3-15 manager2节点加入集群
 
图3-16 manager3节点加入集群
④ woker节点加入
 
图3-17 node1节点加入集群
 
图3-18 node2加入集群
⑤ 查看集群状态
 
图3-19 查看集群状态
3.5 自制镜像php、nginx
3.5.1 制作一个centos7基础镜像
 
图3-20 编写Dockerfile文件
 
图3-21 构建基础镜像
 
图3-22 查看镜像
3.5.2 创建nginx镜像并上传到私有仓库
 
图3-23 查看目录结构
 
图3-24 构建镜像
 
图3-25 push镜像到私有仓库
3.5.3 创建php镜像并上传到私有仓库
需要的文件Dockerfile(php)、php-7.2.3.tar.gz、php-fpm、php.ini、www.conf、Dokerfile的FROM标签需要改为centos：v1，否则centos8编译会报错
 
图3-36 构建php镜像
 
图3-37 push镜像到私有仓库
 
图3-38 查看私有仓库的镜像
3.6 创建一个overlay网络
 
图3-39 查看创建的overlay网络
四、部署服务
4.1 创建mysql服务
① 创建mysql配置文件
 
图4-1 创建mysql配置文件
 
图4-2 配置文件
② 创建mysql服务
 
图4-3 创建mysql服务
③ 查看mysql服务信息
 
图4-4 查看服务信息
④ 登入mysql查看配置信息
 
图4-5 登陆数据库
 
图4-6 查看信息
⑤ 在manager1节点上查看持久化数据
 
图4-7 查看持久化信息
4.2 节点pull镜像
manager1、manager2、manager3、node1、node2节点分别将私有仓库中的镜像pull下来以便创建服务
 
图4-8 manager2节点pull镜像
 
图4-9 manager3节点pull镜像
 
图4-8 node1节点pull镜像
 
图4-9 node2节点pull镜像
4.3 创建php服务
① 创建服务
 
图4-10 创建php服务
② 查看服务
 
图4-11 查看服务
4.4 创建nfs共享存储
① 创建目录、修改nfs配置
 
图4-12 修改配置
 
图4-13 配置文件
② 启动nfs 
 
图4-14 manager1节点
③ 其他worker点安装nfs、启动、尝试挂载
 
图4-15 manager2节点
 
图4-16 manager3节点
 
图4-17 node1节点
 
图4-18 被挂载点添加文件
 
图4-19 挂载点测试
 
图4-20 挂载点测试
 
图4-21 挂载点测试
4.5 创建nginx服务
① 创建服务
 
图4-22 创建nginx服务
② 查看服务
 
图4-23 查看服务

③ 在nfs存储中添加一个nginx配置文件
 
图4-24 nfs中添加配置文件
④ 所有运行nginx节点的nginx容器需要reload
 
图4-25 manager3节点
 
图4-26 node1节点
 
图4-27 node2节点
⑤ 访问测试
 
图4-25 manager1节点测试
 
图4-26 manager3节点测试
4.6 部署wordpress
① 查看wwwroot数据卷
 
图4-27 查看wwwroot数据卷
② 下载WordPress压缩包，放置网站文件（所有节点操作），并将文件解压到wwwroot对应的文件夹中
 
图4-28 manager1放置网站文件
 
图4-29 manager3节点
4.7 wordpress部署
① 访问url
 
图4-30 访问url
② 输入账户密码
 
图4-31 输入账户密码

4.8 高可用负载均衡调度器nginx + keepalived部署
① 安装nginx、keepalived软件包
 
图4-32 安装软件包
 
图4-33 安装软件包
② nginx配置文件（主备一样）
 
图4-34 nginx配置文件
③ keepalived配置文件（Nginx Master）
 
图4-35 keeplived配置文件
④ keepalived配置文件（Nginx Backup）
 
图4-36 keepalived配置文件
⑤ 检查nginx状态的脚本
 
图4-37 nginx状态脚本（master）
# chmod + x /etc/keepalived/check_nginx.sh
⑥ nginx检查脚本
 
图4-38 nginx状态脚本（slave）
# chmod + x /etc/keepalived/check_nginx.sh
⑦ 分别启动软件并设置开机自启
 
图4-39 启动
 
图4-40 启动



⑧ 查看keepalived工作状态
 
图4-41 查看VIP
⑨ VIP访问测试
 


