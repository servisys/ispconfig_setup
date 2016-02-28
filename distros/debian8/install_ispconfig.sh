#---------------------------------------------------------------------
# Function: InstallISPConfig
#    Start the ISPConfig3 intallation script
#---------------------------------------------------------------------
InstallISPConfig() {
  echo "Installing ISPConfig3... "
  cd /tmp
  wget http://www.ispconfig.org/downloads/ISPConfig-3-stable.tar.gz
  tar xfz ISPConfig-3-stable.tar.gz
  cd ispconfig3_install/install/
  if [ $CFG_ISPC == "standard" ]; then
  	echo "Create INI file"
	touch autoinstall.ini
	echo "[install]" > autoinstall.ini
	echo "language=en" >> autoinstall.ini
	echo "install_mode=expert" >> autoinstall.ini
	echo "hostname=$CFG_HOSTNAME_FQDN" >> autoinstall.ini
	echo "mysql_hostname=localhost" >> autoinstall.ini
	echo "mysql_root_user=root" >> autoinstall.ini
	echo "mysql_root_password=$CFG_MYSQL_ROOT_PWD" >> autoinstall.ini
	echo "mysql_database=dbispconfig" >> autoinstall.ini
	echo "mysql_charset=utf8" >> autoinstall.ini
	if [ $CFG_WEBSERVER == "apache" ]; then
		echo "http_server=apache" >> autoinstall.ini
	else
		echo "http_server=nginx" >> autoinstall.ini
	fi
	echo "ispconfig_port=8080" >> autoinstall.ini
	echo "ispconfig_use_ssl=y" >> autoinstall.ini
	echo
	echo "[ssl_cert]" >> autoinstall.ini
	echo "ssl_cert_country=$SSL_COUNTRY" >> autoinstall.ini
    echo "ssl_cert_state=$SSL_STATE" >> autoinstall.ini
	echo "ssl_cert_locality=$SSL_LOCALITY" >> autoinstall.ini
	echo "ssl_cert_organisation=$SSL_ORGANIZATION" >> autoinstall.ini
	echo "ssl_cert_organisation_unit=$SSL_ORGUNIT" >> autoinstall.ini
	echo "ssl_cert_common_name=$CFG_HOSTNAME_FQDN" >> autoinstall.ini
	echo
	echo "[expert]" >> autoinstall.ini
	echo "mysql_ispconfig_user=ispconfig" >> autoinstall.ini
	echo "mysql_ispconfig_password=afStEratXBsgatRtsa42CadwhQ" >> autoinstall.ini
	echo "join_multiserver_setup=$MULTISERVER" >> autoinstall.ini
    echo "mysql_master_hostname=$CFG_MASTER_FQDN" >> autoinstall.ini
	echo "mysql_master_root_user=root" >> autoinstall.ini
	echo "mysql_master_root_password=$CFG_MASTER_MYSQL_ROOT_PWD" >> autoinstall.ini
	echo "mysql_master_database=dbispconfig" >> autoinstall.ini
	echo "configure_mail=$CFG_SETUP_MAIL" >> autoinstall.ini
	if [ $CFG_SETUP_WEB == "y" ]; then
      echo "configure_jailkit=$CFG_JKIT" >> autoinstall.ini
    else
      echo "configure_jailkit=n" >> autoinstall.ini
    fi
    echo "configure_ftp=$CFG_SETUP_WEB" >> autoinstall.ini
	echo "configure_dns=$CFG_SETUP_NS" >> autoinstall.ini
    echo "configure_apache=$CFG_APACHE" >> autoinstall.ini
	echo "configure_nginx=$CFG_NGINX" >> autoinstall.ini
	echo "configure_firewall=y" >> autoinstall.ini
	echo "install_ispconfig_web_interface=$CFG_SETUP_MASTER" >> autoinstall.ini
	echo
	echo "[update]" >> autoinstall.ini
	echo "do_backup=yes" >> autoinstall.ini
	echo "mysql_root_password=$CFG_MYSQL_ROOT_PWD" >> autoinstall.ini
    echo "mysql_master_hostname=$CFG_MASTER_FQDN" >> autoinstall.ini
	echo "mysql_master_root_user=root" >> autoinstall.ini
    echo "mysql_master_root_password=$CFG_MASTER_MYSQL_ROOT_PWD" >> autoinstall.ini
	echo "mysql_master_database=dbispconfig" >> autoinstall.ini
	echo "reconfigure_permissions_in_master_database=no" >> autoinstall.ini
	echo "reconfigure_services=yes" >> autoinstall.ini
    echo "ispconfig_port=8080" >> autoinstall.ini
	echo "create_new_ispconfig_ssl_cert=no" >> autoinstall.ini
    echo "reconfigure_crontab=yes" >> autoinstall.ini
    php -q install.php --autoinstall=autoinstall.ini
  else
    php -q install.php
  fi
  if [ $CFG_SETUP_WEB == "y" ]; then
    if [ $CFG_WEBSERVER == "nginx" ]; then
        /etc/init.d/nginx restart
     else
        /etc/init.d/apache2 restart
     fi
  fi

}
