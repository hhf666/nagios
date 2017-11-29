docker run -d --name nagios-bj  \
  -v /opt/nagios/etc/:/usr/local/nagios/etc/:rw \
  -v /opt/nagios/var/:/usr/local/nagios/var/:rw \
  -v /opt/nagios/share/main.php:/usr/local/nagios/share/main.php:rw \
  -v /opt/nagios/share/images/sblogo.png:/usr/local/nagios/share/images/sblogo.png:rw \
  -v /opt/nagios/share/images/logofullsize.png:/usr/local/nagios/share/images/logofullsize.png:rw \
  -p 8080:80 nagios
docker ps -a
docker ps
