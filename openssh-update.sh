#!/bin/bash
# 创建升级文件夹
cd ~ && mkdir update && cd update
# 下载升级安装包，这里的安装包也可以自行更换版本和地址。
#官方地址如下：
#openssl
#官方下载地址: https://www.openssl.org/source/
#openssh
#官方下载地址:
#https://fastly.cdn.openbsd.org/pub/OpenBSD/OpenSSH/portable/
#zlib
#官方下载地址: http://www.zlib.net/
wget https://openssh-update.oss-cn-beijing.aliyuncs.com/zlib-1.2.13.tar.gz
wget https://openssh-update.oss-cn-beijing.aliyuncs.com/openssl-1.1.1q.tar.gz
wget https://openssh-update.oss-cn-beijing.aliyuncs.com/openssh-9.6p1.tar.gz

# 前置安装和卸载
apt-get -y install gcc
apt-get -y install make 
apt-get -y install libpam0g-dev 
apt-get -y remove openssh-server openssh-client

# 安装zlib
tar -xzvf zlib-1.2.13.tar.gz
cd zlib-1.2.13
./configure --prefix=/usr/local/zlib && make && make install
cd ..;

# 安装openssl
tar -zxvf openssl-1.1.1q.tar.gz && cd openssl-1.1.1q
./config --prefix=/usr/local/ssl shared && make && make install
# 备份原来的openssl
mv /usr/bin/openssl /usr/bin/openssl.bak
mv /usr/include/openssl /usr/include/openssl.bak
# 把安装好的openssl建立软链接到系统位置：
ln -s /usr/local/ssl/bin/openssl /usr/bin/openssl
ln -s /usr/local/ssl/include/openssl /usr/include/openssl
echo '/usr/local/ssl/lib' >> /etc/ld.so.conf
echo "/usr/local/ssl/lib" >> /etc/ld.so.conf.d/openssl.conf
echo "/usr/lib" >> /etc/ld.so.conf.d/libc.conf
ldconfig -v
openssl version -a
cd ..

# 安装openssh
# 备份原openssh
mv /etc/init.d/ssh /etc/init.d/ssh.old
cp -r /etc/ssh /etc/ssh.old
# 安装openssh
tar xf openssh-9.6p1.tar.gz
cd openssh-9.6p1
./configure --prefix=/usr --sysconfdir=/etc/ssh --with-md5-passwords --with-pam --with-zlib=/usr/local/zlib --with-ssl-dir=/usr/local/ssl --with-privsep-path=/var/lib/sshd && make && make install
# 还原ssh配置
cd /etc/ssh
mv sshd_config sshd_config.default
cp ../ssh.old/sshd_config ./
# 使用原来的/etc/init.d/ssh
mv /etc/init.d/ssh.old /etc/init.d/ssh
# 取消注销指定服务
systemctl unmask ssh
# 重启服务
systemctl restart sshd
systemctl status sshd

# 结果输出：
sshd -v
echo "安装完毕"
