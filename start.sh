if [ -z "$(ls -A $NAGIOS_HOME/etc)" ]; then
    echo "Started with empty ETC, copying example data in-place"
    cp -Rp /orig/etc/* /opt/nagios/etc/
fi

if [ -z "$(ls -A $NAGIOS_HOME/var)" ]; then
    echo "Started with empty VAR, copying example data in-place"
    cp -Rp /orig/var/* /opt/nagios/var/
fi

if [ ! -f ${NAGIOS_HOME}/etc/htpasswd.users ] ; then
  htpasswd -c -b -s ${NAGIOS_HOME}/etc/htpasswd.users ${NAGIOSADMIN_USER} ${NAGIOSADMIN_PASS}
  chown -R nagios.nagios ${NAGIOS_HOME}/etc/htpasswd.users
fi

#/usr/local/nagios/bin/nrpe -c /usr/local/nagios/etc/nrpe.cfg -d
/usr/local/pnp4nagios/bin/npcd -d -f /usr/local/pnp4nagios/etc/npcd.cfg

tee /root/.bashrc << -'EOF'
alias ll='ls -l --color=auto'
EOF
source /root/.bashrc
