FROM centos:7.4.1708
MAINTAINER hhf

ENV NAGIOS_HOME            /usr/local/nagios
ENV NG_NAGIOS_CONFIG_FILE  ${NAGIOS_HOME}/etc/nagios.cfg
ENV NG_CGI_DIR             ${NAGIOS_HOME}/sbin
ENV NAGIOS_BRANCH          nagios-4.3.4
ENV NAGIOS_PLUGINS_BRANCH  nagios-plugins-2.2.1
ENV NRPE_BRANCH            nrpe-3.2.1
ENV NAGIOSADMIN_USER       nagiosadmin
ENV NAGIOSADMIN_PASS       nagios


#RUN rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7

#dependency for nagios
RUN yum -y update && yum -y install wget \
    httpd \
    php \
    gcc \
    glibc  \
    glibc-common \
    gd \
    gd-devel \
    make \
    net-snmp \
    zip \
    unzip

#dependency for common
RUN yum -y install vim \
    wget \
    lrzsz \
    ntp \
    tcpdump \
    man \
    nmap \
    telnet \
    mlocate \
    gcc-c++ \
    redhat-lsb \
    openssh-clients \
    dmidecode \
    dos2unix \
    nc \
    traceroute \
    net-tools \
    screen \
    bind-utils \
    glibc.i686 \
    epel-release \
    parallel \
    fakesystemd \
    systemd \
    expect \
    python-setuptools

#RUN easy_install supervisor

#dependency for nrpe
RUN yum -y install openssl openssl-devel
#dependency for pnp4nagios
RUN yum -y install rrdtool perl-rrdtool php-gd

#RUN cd /usr/local/src && \
#    wget http://prdownloads.sourceforge.net/sourceforge/nagios/$NAGIOS_BRANCH.tar.gz && \
#    wget http://nagios-plugins.org/download/$NAGIOS_PLUGINS_BRANCH.tar.gz && \
#    wget https://jaist.dl.sourceforge.net/project/nagios/nrpe-3.x/$NRPE_BRANCH/$NRPE_BRANCH.tar.gz && \
#    wget http://caspian.dotconf.net/menu/Software/SendEmail/sendEmail-v1.56.tar.gz && \
#    wget https://jaist.dl.sourceforge.net/project/pnp4nagios/PNP-0.6/pnp4nagios-0.6.26.tar.gz

COPY src/nagios-4.3.4.tar.gz /usr/local/src/nagios-4.3.4.tar.gz
COPY src/nagios-plugins-2.2.1.tar.gz /usr/local/src/nagios-plugins-2.2.1.tar.gz
COPY src/nrpe-3.2.1.tar.gz /usr/local/src/nrpe-3.2.1.tar.gz
COPY src/sendEmail-v1.56.tar.gz /usr/local/src/sendEmail-v1.56.tar.gz
COPY src/supervisor-3.3.3.tar.gz /usr/local/src/supervisor-3.3.3.tar.gz
COPY src/pnp4nagios-0.6.26.tar.gz /usr/local/src/

RUN ls /usr/local/src/

RUN useradd nagios && \
    groupadd nagcmd && \
    usermod -a -G nagcmd nagios && \
    usermod -a -G nagios,nagcmd apache

RUN cd /usr/local/src && \
    tar zxvf $NAGIOS_BRANCH.tar.gz && \
    cd $NAGIOS_BRANCH && \
    ./configure \
    --prefix=$NAGIOS_HOME \
    --with-nagios-user=nagios \
    --with-nagios-group=nagios \
    --with-command-group=nagcmd \
    && \
    make all && \
    make install && \
    make install-init && \
    make install-config && \
    make install-commandmode && \
    make install-webconf && \
    cp -R contrib/eventhandlers/ $NAGIOS_HOME/libexec/ && \
    chown -R nagios:nagios $NAGIOS_HOME/libexec/eventhandlers && \
    $NAGIOS_HOME/bin/nagios -v $NAGIOS_HOME/etc/nagios.cfg

RUN cd /usr/local/src && \
    tar zxvf $NAGIOS_PLUGINS_BRANCH.tar.gz && \
    cd $NAGIOS_PLUGINS_BRANCH && \
    ./configure \
    --prefix=$NAGIOS_HOME \
    --with-nagios-user=nagios \
    --with-nagios-group=nagios \
    && \
    make && \
    make install 

RUN cd /usr/local/src && \
    tar zxvf $NRPE_BRANCH.tar.gz && \
    cd $NRPE_BRANCH && \
    ./configure \
    --prefix=$NAGIOS_HOME \
    --with-nagios-user=nagios \
    --with-nagios-group=nagios \
    && \
    make all && \
    make install && \
    make install-config && \
    ls -al $NAGIOS_HOME/libexec/check_nrpe && \
    ls -al $NAGIOS_HOME/bin/nrpe && \
    ls -al $NAGIOS_HOME/etc/nrpe.cfg

RUN cd /usr/local/src && \
    tar zxf pnp4nagios-0.6.26.tar.gz && \
    cd pnp4nagios-0.6.26 && \
    ./configure \
    --with-nagios-user=nagios \
    --with-nagios-group=nagios \
    && \
    make all && \
    make fullinstall && \
    mv /usr/local/pnp4nagios/share/install.php /usr/local/pnp4nagios/share/install.php.bak

RUN cd /usr/local/src && \
    tar zxf sendEmail-v1.56.tar.gz && \
    cp -Rp sendEmail-v1.56/sendEmail $NAGIOS_HOME/bin/ && \
    chown nagios:nagios $NAGIOS_HOME/bin/sendEmail    

RUN cd /usr/local/src && \
    tar zxf supervisor-3.3.3.tar.gz && \
    cd supervisor-3.3.3 && python setup.py install

RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime 

RUN mkdir -p /orig/var && mkdir -p /orig/etc  && \
    cp -Rp /usr/local/nagios/var/* /orig/var/ && \
    cp -Rp /usr/local/nagios/etc/* /orig/etc/

RUN mkdir -p /var/log/supervisor
COPY supervisord.conf /etc/supervisord.conf

ADD start.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh

EXPOSE 80 25
VOLUME /usr/local/nagios/var
VOLUME /usr/local/nagios/etc
VOLUME /usr/local/nagios/libexec
VOLUME /usr/local/nagios/share

CMD ["/usr/bin/supervisord","-c","/etc/supervisord.conf"]
