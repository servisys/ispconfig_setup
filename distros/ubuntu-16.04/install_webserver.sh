#---------------------------------------------------------------------
# Function: InstallWebServer Ubuntu 16.04
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
	# apt_install apache2 apache2-doc apache2-utils libapache2-mod-php libapache2-mod-fastcgi libapache2-mod-fcgid apache2-suexec-pristine libapache2-mod-python php7.0-fpm libruby
	apt_install apache2 apache2-doc apache2-utils libapache2-mod-php libapache2-mod-fcgid apache2-suexec-pristine libruby libapache2-mod-python
	echo -e "[${green}DONE${NC}]\n"
	echo -n "Installing PHP and modules... "
	# apt_install php7.0 php7.0-common php7.0-gd php7.0-dev php7.0-mysqlnd php7.0-imap php7.0-cli php7.0-cgi php-pear php-auth php7.0-mcrypt php7.0-curl php7.0-intl php7.0-pspell php7.0-recode php7.0-sqlite3 php7.0-tidy php7.0-xmlrpc php7.0-xsl php-memcached php-imagick php-gettext php7.0-zip php7.0-mbstring php7.0-opcache php-apcu php7.0-bz2 php-redis
	apt_install php7.0 php7.0-common php7.0-gd php7.0-mysql php7.0-imap php7.0-cli php7.0-cgi php-pear php-auth php7.0-mcrypt php7.0-curl php7.0-intl php7.0-pspell php7.0-recode php7.0-sqlite3 php7.0-tidy php7.0-xmlrpc php7.0-xsl php-memcache php-imagick php-gettext php7.0-zip php7.0-mbstring
	echo -e "[${green}DONE${NC}]\n"
	echo -n "Installing APCu... "
	apt_install php7.0-opcache php-apcu
	echo -e "[${green}DONE${NC}]\n"
	echo -n "Installing PHP-FPM... "
	apt_install libapache2-mod-fastcgi php7.0-fpm
	echo -e "[${green}DONE${NC}]\n"

	echo -n "Disabling HTTP_PROXY... "
  	echo "<IfModule mod_headers.c>
    RequestHeader unset Proxy early
	</IfModule>" | tee /etc/apache2/conf-available/httpoxy.conf > /dev/null 2>&1
	a2enconf httpoxy > /dev/null 2>&1
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
	
	echo -n "Activating Apache modules... "
	a2enmod suexec > /dev/null 2>&1
	a2enmod rewrite > /dev/null 2>&1
	a2enmod ssl > /dev/null 2>&1
	a2enmod actions > /dev/null 2>&1
	a2enmod include > /dev/null 2>&1
	a2enmod cgi > /dev/null 2>&1
	a2enmod dav_fs > /dev/null 2>&1
	a2enmod dav > /dev/null 2>&1
	a2enmod auth_digest > /dev/null 2>&1
	a2enmod headers > /dev/null 2>&1
	a2enmod fastcgi > /dev/null 2>&1
	a2enmod alias > /dev/null 2>&1
	# a2enmod fcgid > /dev/null 2>&1
	echo -e "[${green}DONE${NC}]\n"
	echo -n "Restarting Apache... "
	service apache2 restart
	echo -e "[${green}DONE${NC}]\n"

	echo -n "Installing needed programs for PHP and Apache (mcrypt, etc.)... "
	apt_install mcrypt imagemagick memcached curl tidy snmp redis-server
	echo -e "[${green}DONE${NC}]\n"
  elif [ "$CFG_WEBSERVER" == "nginx" ]; then
	CFG_NGINX=y
	CFG_APACHE=n
	echo -n "Installing Web server (nginx) and modules... "
	service apache2 stop
	hide_output update-rc.d -f apache2 remove
	apt_install nginx
	service nginx start
	echo -e "[${green}DONE${NC}]\n"
	
	# apt_install php7.0-opcache php7.0-fpm php7.0 php7.0-common php7.0-gd php7.0-mysql php7.0-imap php7.0-cli php7.0-cgi php-pear php-auth php7.0-mcrypt mcrypt imagemagick libruby php7.0-curl php7.0-intl php7.0-pspell php7.0-recode php7.0-sqlite3 php7.0-tidy php7.0-xmlrpc php7.0-xsl memcached php-memcache php-imagick php-gettext php7.0-zip php7.0-mbstring php7.0-opcache php-apcu
	echo -n "Installing PHP-FPM... "
	apt_install php7.0-fpm
	echo -e "[${green}DONE${NC}]\n"
	echo -n "Installing PHP and modules... "
	apt_install php7.0-opcache php7.0 php7.0-common php7.0-gd php7.0-mysql php7.0-imap php7.0-cli php7.0-cgi php-pear php-auth php7.0-mcrypt libruby php7.0-curl php7.0-intl php7.0-pspell php7.0-recode php7.0-sqlite3 php7.0-tidy php7.0-xmlrpc php7.0-xsl php-memcache php-imagick php-gettext php7.0-zip php7.0-mbstring
	echo -e "[${green}DONE${NC}]\n"
	echo -n "Installing APCu... "
	apt_install php-apcu
	
	sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php/7.0/fpm/php.ini
	TIME_ZONE=$(echo "$TIME_ZONE" | sed -n 's/ (.*)$//p')
	sed -i "s/;date.timezone =/date.timezone=\"${TIME_ZONE//\//\\/}\"/" /etc/php/7.0/fpm/php.ini
	echo -e "[${green}DONE${NC}]\n"
	echo -n "Reloading PHP-FPM... "
	service php7.0-fpm reload
	echo -e "[${green}DONE${NC}]\n"
	
	echo -n "Installing fcgiwrap... "
	apt_install fcgiwrap
	echo -e "[${green}DONE${NC}]\n"
	echo "phpmyadmin phpmyadmin/reconfigure-webserver multiselect none" | debconf-set-selections
	
	if [ "$CFG_PHPMYADMIN" == "yes" ]; then
		echo "==========================================================================================="
		echo "Attention: When asked 'Configure database for phpmyadmin with dbconfig-common?' select 'NO'"
		echo "Due to a bug in dbconfig-common, this can't be automated."
		echo "==========================================================================================="
		echo "Press ENTER to continue... "
		read DUMMY
		echo -n "Installing phpMyAdmin... "
		apt-get -y install phpmyadmin
		echo "With nginx phpMyAdmin is accessibile at  http://$CFG_HOSTNAME_FQDN:8081/phpmyadmin or http://${IP_ADDRESS[0]}:8081/phpmyadmin"
		echo -e "[${green}DONE${NC}]\n"
	fi
	
	echo -n "Installing needed programs for PHP and nginx (mcrypt, etc.)... "
	apt_install mcrypt imagemagick memcached curl tidy snmp redis-server
	echo -e "[${green}DONE${NC}]\n"
	
	phpenmod mcrypt
	phpenmod mbstring
  fi

  # if [ "$CFG_XCACHE" == "yes" ]; then  
		# echo -n "Installing XCache... "
		# apt_install php7-xcache
		# echo -e "[${green}DONE${NC}]\n"
  # fi

  echo -n "Installing Let's Encrypt (letsencrypt)... "
  apt_install letsencrypt
  echo -e "[${green}DONE${NC}]\n"
}
