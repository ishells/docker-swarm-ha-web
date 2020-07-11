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

![image.png](https://www.ishells.cn/upload/2020/07/image-3624eea66de94902896ca50a0db40a4b.png)


### 三、集群搭建准备：
#### 3.1 集群拓扑
![image.png](https://www.ishells.cn/upload/2020/07/image-9c622646e8404a42b00633c0728304f3.png)
>
#### 3.2 二进制安装docker（ 可使用yum 安装docker ）
>>[docker下载地址](https://download.docker.com/linux/static/stable/x86_64/docker-19.03.9.tgz)
>>#### 3.2.1  manager1节点
>>
>> ① manager1解压二进制包
>>
![image.png](https://www.ishells.cn/upload/2020/07/image-c5dae8571108496ab18796755576ec73.png)
>>
>> ② 设置systemed管理
>>
![image.png](https://www.ishells.cn/upload/2020/07/image-c283ecfd94a141a393ce5b32818849cd.png)
>>
>> ③ 启动并开机自启
>>
![image.png](https://www.ishells.cn/upload/2020/07/image-d177c20b208b41aa873f7b11c02bcf94.png)
>>
>>#### 3.2.2 manager2节点 
>>
>> ① manager2解压安装包
>>
>>

![image.png](https://www.ishells.cn/upload/2020/07/image-4cbdae8a412d4dce8638fb2e9cec02a6.png) 

>>
>> ② 设置systemed管理
>>
>>

![image.png](https://www.ishells.cn/upload/2020/07/image-9866b7571dfe49ccadda988edee4aa77.png)

>>
>> ③ 启动并开机自启
>>
>>

![image.png](https://www.ishells.cn/upload/2020/07/image-04900c5c223242e8bc74677ffeec4563.png)

>>
>>#### 3.2.3 manager3节点
>>
>> ① manager3节点解压二进制包
>>

![image.png](https://www.ishells.cn/upload/2020/07/image-8400f74b43864340911374ecf19cdda9.png)

>>
>> ② 设置systemd管理并开机自启
>>

![image.png](https://www.ishells.cn/upload/2020/07/image-dd8ac330be024ec181399ad8ded4f873.png)

>>
>>#### 3.2.4 node1节点
>>
>> ① node1节点解压
>>

![image.png](https://www.ishells.cn/upload/2020/07/image-d75092792c24411aa85cf2a265304343.png)

>>
>> ② 设置systemd管理
>>

![image.png](https://www.ishells.cn/upload/2020/07/image-ff8cf0ecb1844ffdaa082cde86cb4733.png)

>>
#### 3.3 搭建私有镜像仓库：
>> ① docker pull registry拉取registry镜像仓库
>>

![image.png](https://www.ishells.cn/upload/2020/07/image-a2d35a6436964d1b8219cce7613a0f29.png)

>>
>>② 启动镜像容器并挂载本地目录
>>
>>默认情况下，会将仓库存放于容器内的/var/lib/registry目录下，这样如果容器被删除，则存放于容器中的镜像也会丢失，所以我们一般情况下会指定本地一个目录

![image.png](https://www.ishells.cn/upload/2020/07/image-97952a063b254860985298de1398600b.png)

>>
#### 3.4 集群初始化
>
>> ① 获取worker节点加入的token

![image.png](https://www.ishells.cn/upload/2020/07/image-e6aaadf6595c45bf9a3fc07b40e9e6a5.png)

>>
>>② 获取manager节点加入的token

![image.png](https://www.ishells.cn/upload/2020/07/image-1345b6ac5a474ec8bd23c20f3f9644ab.png)

>>
>> ③ manager节点加入

![image.png](https://www.ishells.cn/upload/2020/07/image-7e2db56cff554377beab941de7690b58.png)

>>

![image.png](https://www.ishells.cn/upload/2020/07/image-a0c2ec46c46b43e6ab960673bc51dbf1.png)

>>
>> ④ woker节点加入

![image.png](https://www.ishells.cn/upload/2020/07/image-a73a73ea76794c7d9ba57abef61fa840.png)

>>

![image.png](https://www.ishells.cn/upload/2020/07/image-542c0b6361584746b64c15c8eff58b40.png)

>>
>> ⑤ 查看集群状态

![image.png](https://www.ishells.cn/upload/2020/07/image-d55bcc265d74449888beea85eb79c6ac.png)
 
#### 3.5 自制镜像php、nginx
>>#### 3.5.1 制作一个centos7基础镜像
>>
>> ① 编写Dockerfile文件

![image.png](https://www.ishells.cn/upload/2020/07/image-8aa768bf5eb94f4bb222f2f0a286dee6.png)

>>
>> ② 构建基础镜像

![image.png](https://www.ishells.cn/upload/2020/07/image-4d53510c93724ea0845a0945027118fb.png)

>>
>> ③ 查看镜像

![image.png](https://www.ishells.cn/upload/2020/07/image-9ca2de96e13348329bdbaeada222c593.png)

>>
>>#### 3.5.2 创建nginx镜像并上传到私有仓库
>>
>> ① 查看目录结构

![image.png](https://www.ishells.cn/upload/2020/07/image-e23332dd30cf4f5090984ddc366000fe.png)

>>
>> ② 构建镜像

![image.png](https://www.ishells.cn/upload/2020/07/image-2e10f4076ecb40669d94dca3579b3fde.png)

>>
>> ③ push镜像到私有仓库

![image.png](https://www.ishells.cn/upload/2020/07/image-2bda9f21022c4c4eb9d33c06e285451f.png)

>>
>>#### 3.5.3 创建php镜像并上传到私有仓库
>>
>>需要的文件Dockerfile(php)、php-7.2.3.tar.gz、php-fpm、php.ini、www.conf、Dokerfile的FROM标签需要改为centos：v1，否则centos8编译会报错
>> ① 构建php镜像

![image.png](https://www.ishells.cn/upload/2020/07/image-280b7b8c1b584b74af06964b93668151.png)

>>
>> ② push镜像到私有仓库

![image.png](https://www.ishells.cn/upload/2020/07/image-cdae28e72bea41f8a5fb24e06ef199d0.png)

>>
>> ③ 查看私有仓库的镜像

![image.png](https://www.ishells.cn/upload/2020/07/image-1cab6fafdfa94634957aafbcdc01e141.png)

>>
>>#### 3.6 创建一个overlay网络
>>
>> ① 查看创建的overlay网络

![image.png](https://www.ishells.cn/upload/2020/07/image-a7aa06962d064e5586dc9643f4ecd2b8.png) 

>>
### 四、部署服务
#### 4.1 创建mysql服务
>> ① 创建mysql配置文件

![image.png](https://www.ishells.cn/upload/2020/07/image-449ee501273d4e7f837967900bbaa004.png)

>>
>> 配置文件

![image.png](https://www.ishells.cn/upload/2020/07/image-ff64c5a83d9841869cc14f5131d2df6d.png)

>>
>> ② 创建mysql服务

![image.png](https://www.ishells.cn/upload/2020/07/image-827d08d566b243d2a71278da049f50f1.png)

>> 
>> ③ 查看mysql服务信息

![image.png](https://www.ishells.cn/upload/2020/07/image-bf30ee4ad83f4ba084a42eb18e6cf445.png)

>>
>> ④ 登入mysql查看配置信息（ 物理机如果安装的有mysql，可以通过-h 容器IP登入mysql的容器，在配置文件中设置过 ）

![image.png](https://www.ishells.cn/upload/2020/07/image-d76189822de245faa8fbbd8116b84e40.png)

>>
>> 查看信息

![image.png](https://www.ishells.cn/upload/2020/07/image-f689db3b920e44edbcd3bca0f5d336ae.png)

>>
>> ⑤ 在manager1节点上查看持久化数据
>>

![image.png](https://www.ishells.cn/upload/2020/07/image-bf48915fc8b54f45a2e2b78a937adc7e.png)

>>
#### 4.2 节点pull镜像
>> manager1、manager2、manager3、node1、node2节点分别将私有仓库中的镜像pull下来以便创建服务
>>
>> ① manager2节点pull镜像

![image.png](https://www.ishells.cn/upload/2020/07/image-2c1a276f68974f048cb7ee80f5c1d94b.png)

>>
>> ② manager3节点pull镜像

![image.png](https://www.ishells.cn/upload/2020/07/image-4388004c8b6f4225b4d1e8a454aacef4.png)

>>
>> ③ node1节点pull镜像

![image.png](https://www.ishells.cn/upload/2020/07/image-0b9912c79d32402795d8484dbcbf45b7.png)

>>
>> ④ node2节点pull镜像

![image.png](https://www.ishells.cn/upload/2020/07/image-5801937a0ca448508028e0d88903110e.png)

>>
#### 4.3 创建php服务
>>
>> ① 创建php服务

![image.png](https://www.ishells.cn/upload/2020/07/image-f1058edc17854d919207a6fe38343574.png)

>>
>> ② 查看服务

![image.png](https://www.ishells.cn/upload/2020/07/image-05f49dd70d954589abb67387659346da.png)

>>
#### 4.4 创建nfs共享存储
>>
>> ① 创建目录、修改nfs配置

![image.png](https://www.ishells.cn/upload/2020/07/image-7e0e240b12104ea28eb7b0554eaf67bb.png) 

>>
>> 配置文件

![image.png](https://www.ishells.cn/upload/2020/07/image-6819408ac6234c1ab5dbea6d6947acd2.png)

>>
>> ② manager1节点启动nfs 

![image.png](https://www.ishells.cn/upload/2020/07/image-85de1c8f794646a78c90be1fbda69ebd.png)

>>
>>
>> ③ 其他worker点安装nfs、启动、尝试挂载
>> 
>> manager2节点

![image.png](https://www.ishells.cn/upload/2020/07/image-482ccf2854f84266b32e7010d37d0052.png)

>>
>> manager3节点

![image.png](https://www.ishells.cn/upload/2020/07/image-8516af6bd56246b3a50d44b8d550909a.png)

>>
>> node1节点

![image.png](https://www.ishells.cn/upload/2020/07/image-e653691b01894a51b89a463f6de5ff32.png)

>> 
>> 被挂载点添加文件

![image.png](https://www.ishells.cn/upload/2020/07/image-56a2c99179694049b33fee9b2d073bdf.png)

>>
>> manager2挂载点测试

![image.png](https://www.ishells.cn/upload/2020/07/image-0695f045c4dd4cfda0a131f3ce8762a0.png)

>>
>> node1挂载点测试

![image.png](https://www.ishells.cn/upload/2020/07/image-869b3bc1ce0845149af550b46c0856c8.png)

>>
>> node2挂载点测试

![image.png](https://www.ishells.cn/upload/2020/07/image-51b0440cb1664525be0d8463e769f6b1.png)

>>
>>

#### 4.5 创建nginx服务
>> ① 创建nginx服务

![image.png](https://www.ishells.cn/upload/2020/07/image-6be81e2463eb4461924d0d70d602cf35.png)

>>
>> ② 查看服务

![image.png](https://www.ishells.cn/upload/2020/07/image-7a291ca349e248ffa2334d027dc395e7.png)

>>
>> ③ 在nfs存储中添加一个nginx配置文件

![image.png](https://www.ishells.cn/upload/2020/07/image-51c87a446b974716bdd0674eb0a06b97.png)

>>
>> ④ 所有运行nginx节点的nginx容器需要reload
>>
>> manager3节点

![image.png](https://www.ishells.cn/upload/2020/07/image-c47ffef8f83b4adb997a3ea161b5d198.png)

>>
>> node1节点

![image.png](https://www.ishells.cn/upload/2020/07/image-01557b444db94ac5abb3f839ec432f66.png)

>>
>> node2节点

![image.png](https://www.ishells.cn/upload/2020/07/image-9beac1cdd3ff43d8b802e0fc445cdab3.png)

>>
>> ⑤ 访问测试
>> 
>> manager1节点测试

![image.png](https://www.ishells.cn/upload/2020/07/image-dbd8a507b9614287b3e03e7647e9cb30.png)

>>
>> manager3节点测试

![image.png](https://www.ishells.cn/upload/2020/07/image-4ee05d03f7af4407aaa5ddd54510a3f6.png)

>>
>>#### 4.6 部署wordpress
>>
>> ① 查看wwwroot数据卷

![image.png](https://www.ishells.cn/upload/2020/07/image-0e960ac0791a46eaaed367e0c6645b7c.png)

>>
>> ② 下载WordPress压缩包，放置网站文件（所有节点操作），并将文件解压到wwwroot对应的文件夹中
>>
>> manager1放置网站文件

![image.png](https://www.ishells.cn/upload/2020/07/image-85a2e3ab8c84406e9d67054e3f319f6c.png)

>>
>> manager3节点

![image.png](https://www.ishells.cn/upload/2020/07/image-53dfd3e48f174845b4a80dd052b1b7a3.png)


#### 4.7 wordpress部署
>> ① 访问url

![image.png](https://www.ishells.cn/upload/2020/07/image-308d4d6d43f84d0cba261dd25fc6c9f7.png)

>>
>> ② 输入账户密码

![image.png](https://www.ishells.cn/upload/2020/07/image-dd5d11c003014c2c93db9c611dd651b7.png)

>>
#### 4.8 高可用负载均衡调度器nginx + keepalived部署
>> ① 安装nginx、keepalived软件包

![image.png](https://www.ishells.cn/upload/2020/07/image-8c119148e67f4d86b09c00512725b2de.png)

>>

![image.png](https://www.ishells.cn/upload/2020/07/image-4135791d0b744183b1ea6dcbb0704d3f.png)

>>
>> ② nginx配置文件（主备一样）

![image.png](https://www.ishells.cn/upload/2020/07/image-385ea47ababd4dd48d931eece36dff42.png)

>>
>> ③ keepalived配置文件（Nginx Master）

![image.png](https://www.ishells.cn/upload/2020/07/image-2176bda24c3440f1a4e427804ca9ab6a.png)

>>
>> ④ keepalived配置文件（Nginx Backup）

![image.png](https://www.ishells.cn/upload/2020/07/image-eb90d8b91881488d952e26658b08fa8b.png)

>>
>> ⑤ nginx状态脚本（master）

![image.png](https://www.ishells.cn/upload/2020/07/image-e7fa918befc8467c835184a3ed726e1c.png)

>>
>>```
>># chmod + x /etc/keepalived/check_nginx.sh
>>```
>>
>> ⑥ nginx状态脚本（slave）

![image.png](https://www.ishells.cn/upload/2020/07/image-1d6c2072901b47b4a2d68652fa8e247e.png)

>>
>>```
>># chmod + x /etc/keepalived/check_nginx.sh
>>```
>>
>> ⑦ 分别启动软件并设置开机自启

![image.png](https://www.ishells.cn/upload/2020/07/image-259d48d72aa64363aeca7b31fdd2c126.png)

>>

![image.png](https://www.ishells.cn/upload/2020/07/image-ca2abe10fcf24bdfb961a1a76411ad3e.png)

>>
>> ⑧ 查看keepalived工作状态

![image.png](https://www.ishells.cn/upload/2020/07/image-caea9ae21a4c4cf3a8e885ff35f17da9.png)

>>
>> ⑨ VIP访问测试

![image.png](https://www.ishells.cn/upload/2020/07/image-816c9128e9ea4b5cb016f2e9f368a02b.png)

### 五、集群高可用测试
#### 5.1 节点的高可用测试
>> 
>> ① 模拟leader manager节点的宕机

![image.png](https://www.ishells.cn/upload/2020/07/image-a2539908cdd047209c9dbd4f3bda41cb.png)

>>
>> ② 查看是否产生新的leader
>>
>> manager2节点成为新的leader

![image.png](https://www.ishells.cn/upload/2020/07/image-f7fc0611bd7440c290a996bd42b3dc34.png)

>>
#### 5.2 service的高可用测试
>>
>> ① 杀掉mysql的一个副本

![image.png](https://www.ishells.cn/upload/2020/07/image-8dfb733db57a4f40a81ec68bf7bd657b.png)

>>
>> ② 很快又生成一个新的mysql容器

![image.png](https://www.ishells.cn/upload/2020/07/image-a50721a91b1943a8a5cb5f08431ec1a8.png)

>>
>> ③ 通过scale动态扩容副本数量

![image.png](https://www.ishells.cn/upload/2020/07/image-6efd57234ee84183b82139b043c2a220.png)

>>
### 5.3 web高可用测试
>>
>> ① 所有节点都可访问web服务
>>
>> manager1节点

![image.png](https://www.ishells.cn/upload/2020/07/image-9998f2f9558f4157969ab554dec58b67.png)

>>
>> manager2节点

![image.png](https://www.ishells.cn/upload/2020/07/image-a2988c753b4e4d26892de3c963c10328.png)

>>
>> manager3节点

![image.png](https://www.ishells.cn/upload/2020/07/image-145c7f57206d4eacbbe590eeb95556a6.png)

>>
>> node1节点

![image.png](https://www.ishells.cn/upload/2020/07/image-2cd4ab37c3b147bc8443fc3bfa3ccd2b.png)

>>
>> node2节点

![image.png](https://www.ishells.cn/upload/2020/07/image-e14d4164a8854ac7abca385cc3b1b47b.png)

#### 5.3 负载调度器高可用测试
>>
>> ① 通过VIP可以正常访问服务

![image.png](https://www.ishells.cn/upload/2020/07/image-c9e9036a48d44c028f5a5b83594dc0b5.png)

>>
>> ② 模拟master调度器宕机

![image.png](https://www.ishells.cn/upload/2020/07/image-e387575156cf49139fe78f04b752c0b2.png)

>>
>> ③ 查看VIP平滑过渡到slave节点

![image.png](https://www.ishells.cn/upload/2020/07/image-45154a92e50e4138a96945b641d04ec6.png)

>>
>> ④ 再次查看VIP是否仍然可访问
>> 
>> VIP仍然正常访问

![image.png](https://www.ishells.cn/upload/2020/07/image-a9013573b79d423e8983fce4ab7b2268.png)
