## nagios

# 1、启动
docker run -d --name nagios --restart always -p 8080:80 nagios

# 2、拷贝相关目录到宿主机后，挂载启动
docker run -d --name nagios --restart always \
  -v /opt/nagios/etc/:/usr/local/nagios/etc/:rw \
  -v /opt/nagios/var/:/usr/local/nagios/var/:rw \
  -v /opt/nagios/share/main.php:/usr/local/nagios/share/main.php:rw \
  -v /opt/nagios/share/images/sblogo.png:/usr/local/nagios/share/images/sblogo.png:rw \
  -v /opt/nagios/share/images/logofullsize.png:/usr/local/nagios/share/images/logofullsize.png:rw \
  -p 8080:80 nagios

# 宿主机

注：确保目录挂载正确
Q：
无法修改文件 \
A：
useradd -s /sbin/nologin nagios  \
passwd -l nagios  \
chown -R nagios:nagios /opt/nagios/  

# web登录
http://ip:8080/nagios
默认账号/密码：nagiosadmin/nagios

