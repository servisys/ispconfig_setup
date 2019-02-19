#---------------------------------------------------------------------
# Function: InstallWebServer Ubuntu 14.04
#    Install and configure Apache2, php + modules
#---------------------------------------------------------------------
InstallWebServer() {
  
  if [ "$CFG_WEBSERVER" == "apache" ]; then
	CFG_NGINX=n
	CFG_APACHE=y
	echo -n "Installing Web server (Apache) and modules... "
	echo "phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2" | debconf-set-selections
	# - DISABLED DUE TO A BUG IN DBCONFIG - echo "phpmyadmin phpmyadmin/dbconfig-install boolean false" | debconf-set-selections
	echo "dbconfig-common dbconfig-common/dbconfig-install boolean false" | debconf-set-selections
	# apt_install apache2 apache2-doc apache2-mpm-prefork apache2-utils libapache2-mod-php5 libapache2-mod-fastcgi libapache2-mod-fcgid apache2-suexec libapache2-mod-passenger libapache2-mod-python libexpat1 ssl-cert libruby 
	apt_install apache2 apache2-doc apache2-utils libapache2-mod-php5 libapache2-mod-fcgid apache2-suexec libapache2-mod-suphp libruby libapache2-mod-python
	echo -e "[${green}DONE${NC}]\n"
	echo -n "Installing PHP and modules... "
	# apt_install php5 php5-common php5-dev php5-gd php5-mysqlnd php5-imap php5-cli php5-cgi php-pear php-auth php5-fpm php5-mcrypt php5-imagick php5-curl php5-intl php5-memcached php5-pspell php5-recode php5-snmp php5-sqlite php5-tidy php5-xmlrpc php5-xsl
	apt_install php5 php5-common php5-gd php5-mysql php5-imap php5-cli php5-cgi php-pear php-auth php5-mcrypt php5-imagick php5-curl php5-intl php5-memcache php5-memcached php5-ming php5-ps php5-pspell php5-recode php5-snmp php5-sqlite php5-tidy php5-xmlrpc php5-xsl
	echo -e "[${green}DONE${NC}]\n"
	echo -n "Installing PHP-FPM... "
	apt_install libapache2-mod-fastcgi php5-fpm
	echo -e "[${green}DONE${NC}]\n"
	
  if [ "$CFG_PHPMYADMIN" == "yes" ]; then
	echo "==========================================================================================="
	echo "Attention: When asked 'Configure database for phpmyadmin with dbconfig-common?' select 'NO'"
	echo "Due to a bug in dbconfig-common, this can't be automated."
	echo "==========================================================================================="
	echo "Press ENTER to continue... "
	read DUMMY
	echo -n "Installing phpMyAdmin... "
	apt-get -y install phpmyadmin
	echo -e "[${green}DONE${NC}]\n"
  fi
  
  if [ "$CFG_XCACHE" == "yes" ]; then
	echo -n "Installing XCache... "
	apt_install php5-xcache
	echo -e "[${green}DONE${NC}]\n"
	echo -n "Restarting Apache... "
	hide_output service apache2 restart
	echo -e "[${green}DONE${NC}]\n"
  fi
  
	echo -n "Installing needed programs for PHP and Apache (mcrypt, etc.)... "
	apt_install mcrypt imagemagick memcached curl tidy snmp
	echo -e "[${green}DONE${NC}]\n"
	
	echo -n "Activating Apache modules... "
	a2enmod suexec > /dev/null 2>&1
	a2enmod rewrite > /dev/null 2>&1
	a2enmod ssl > /dev/null 2>&1
	a2enmod actions > /dev/null 2>&1
	a2enmod include > /dev/null 2>&1
	a2enmod dav_fs > /dev/null 2>&1
	a2enmod cgi > /dev/null 2>&1
	a2enmod dav > /dev/null 2>&1
	a2enmod auth_digest > /dev/null 2>&1
	a2enmod fastcgi > /dev/null 2>&1
	a2enmod alias > /dev/null 2>&1
	# a2enmod fcgid > /dev/null 2>&1
	echo -e "[${green}DONE${NC}]\n"
	echo -n "Restarting Apache... "
	hide_output service apache2 restart
	echo -e "[${green}DONE${NC}]\n"
  
  elif [ "$CFG_WEBSERVER" == "nginx" ]; then
	CFG_NGINX=y
	CFG_APACHE=n
	echo -n "Installing Web server (nginx) and modules... "
	# hide_output service apache2 stop
	# hide_output update-rc.d -f apache2 remove
	apt_install nginx
	hide_output service nginx start 
	# apt_install php5-fpm php5-mysqlnd php5-curl php5-gd php5-intl php-pear php5-imagick php5-imap php5-mcrypt php5-memcache php5-memcached php5-pspell php5-recode php5-snmp php5-sqlite php5-tidy php5-xmlrpc php5-xsl memcached php-apc
	echo -e "[${green}DONE${NC}]\n"
	echo -n "Installing PHP-FPM... "
	apt_install php5-fpm
	apt_install php5-mysql php5-curl php5-gd php5-intl php-pear php5-imagick php5-imap php5-mcrypt php5-memcache php5-ming php5-ps php5-pspell php5-recode php5-snmp php5-sqlite php5-tidy php5-xmlrpc php5-xsl
	echo -e "[${green}DONE${NC}]\n"
	echo -n "Installing APC... "
	apt_install php-apc
	sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php5/fpm/php.ini
	TIME_ZONE=$(echo "$TIME_ZONE" | sed -n 's/ (.*)$//p')
	sed -i "s/;date.timezone =/date.timezone=\"${TIME_ZONE//\//\\/}\"/" /etc/php5/fpm/php.ini
	#sed -i "s/#/;/" /etc/php5/conf.d/ming.ini
	echo -e "[${green}DONE${NC}]\n"
	echo -n "Reloading PHP-FPM... "
	hide_output service php5-fpm reload
	echo -e "[${green}DONE${NC}]\n"
	echo -n "Installing fcgiwrap... "
	apt_install fcgiwrap
	echo -e "[${green}DONE${NC}]\n"
	echo "phpmyadmin phpmyadmin/reconfigure-webserver multiselect none" | debconf-set-selections
		# - DISABLED DUE TO A BUG IN DBCONFIG - echo "phpmyadmin phpmyadmin/dbconfig-install boolean false" | debconf-set-selections
		echo "dbconfig-common dbconfig-common/dbconfig-install boolean false" | debconf-set-selections
	if [ "$CFG_PHPMYADMIN" == "yes" ]; then
		echo "==========================================================================================="
		echo "Attention: When asked 'Configure database for phpmyadmin with dbconfig-common?' select 'NO'"
		echo "Due to a bug in dbconfig-common, this can't be automated."
		echo "==========================================================================================="
		echo "Press ENTER to continue... "
		read DUMMY
		echo -n "Installing phpMyAdmin... "
		apt-get -y install phpmyadmin
		echo "With nginx phpMyAdmin is accessible at http://$CFG_HOSTNAME_FQDN:8081/phpmyadmin or http://${IP_ADDRESS[0]}:8081/phpmyadmin"
		echo -e "[${green}DONE${NC}]\n"
	fi
	echo -n "Installing needed programs for PHP and nginx (mcrypt, etc.)... "
	apt_install mcrypt imagemagick memcached curl tidy snmp
	echo -e "[${green}DONE${NC}]\n"
  fi
	echo -n "Installing Let's Encrypt (Certbot)... "
	mkdir /opt/certbot
	cd /opt/certbot
	wget -q https://dl.eff.org/certbot-auto
	chmod a+x ./certbot-auto
	echo "==========================================================================================="
	echo "Attention: answer no to next Question Dialog"
	echo "==========================================================================================="
	echo "Press ENTER to continue... "
	read DUMMY
	echo -n "Installing Certbot-auto... "
	./certbot-auto -n --os-packages-only
  echo -e "[${green}DONE${NC}]\n"
}
