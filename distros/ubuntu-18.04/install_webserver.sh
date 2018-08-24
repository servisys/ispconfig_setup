#---------------------------------------------------------------------
# Function: InstallWebServer Debian 8
#    Install and configure Apache2, php + modules
#---------------------------------------------------------------------
InstallWebServer() {
  
  if [ "$CFG_WEBSERVER" == "apache" ]; then
	echo -n "Installing Apache and Modules... "
	echo "phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2" | debconf-set-selections
	# - DISABLED DUE TO A BUG IN DBCONFIG - echo "phpmyadmin phpmyadmin/dbconfig-install boolean false" | debconf-set-selections
	echo "dbconfig-common dbconfig-common/dbconfig-install boolean false" | debconf-set-selections
	apt-get -yqq install apache2 apache2-doc apache2-utils libapache2-mod-php libapache2-mod-fastcgi libapache2-mod-fcgid apache2-suexec-pristine libapache2-mod-python php7.2-fpm libruby > /dev/null 2>&1
	echo -e "[${green}DONE${NC}]\n"
	echo -n "Installing PHP and Modules... "
	apt-get -yqq install php7.2 php7.2-common php7.2-gd php7.2-dev php7.2-mysqlnd php7.2-imap php7.2-cli php7.2-cgi php-pear php7.2-curl php7.2-intl php7.2-pspell php7.2-recode php7.2-sqlite3 php7.2-tidy php7.2-xmlrpc php7.2-xsl php-memcached php-imagick php-gettext php7.2-zip php7.2-mbstring php7.2-opcache php-apcu php7.2-bz2 php-redis > /dev/null 2>&1
	echo -e "[${green}DONE${NC}]\n"

	
  	echo "<IfModule mod_headers.c>
    RequestHeader unset Proxy early
	</IfModule>" | tee /etc/apache2/conf-available/httpoxy.conf > /dev/null 2>&1
	
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
	
	echo -n "Activating Apache2 Modules... "
	a2enmod suexec > /dev/null 2>&1
	a2enmod rewrite > /dev/null 2>&1
	a2enmod ssl > /dev/null 2>&1
	a2enmod actions > /dev/null 2>&1
	a2enmod include > /dev/null 2>&1
	a2enmod dav_fs > /dev/null 2>&1
	a2enmod dav > /dev/null 2>&1
	a2enmod auth_digest > /dev/null 2>&1
	a2enmod fastcgi > /dev/null 2>&1
	a2enmod alias > /dev/null 2>&1
	a2enmod fcgid > /dev/null 2>&1
	a2enconf httpoxy > /dev/null 2>&1
	service apache2 restart > /dev/null 2>&1

  else
	
	echo -n "Installing NGINX and Modules... "
	service apache2 stop > /dev/null 2>&1
	update-rc.d -f apache2 remove > /dev/null 2>&1
	apt-get -yqq install nginx > /dev/null 2>&1
	service nginx start 
	
	echo -n "Installing PHP and Modules... "
	apt-get -yqq install php7.2-opcache php7.2-fpm php7.2 php7.2-common php7.2-gd php7.2-mysql php7.2-imap php7.2-cli php7.2-cgi php-pear mcrypt imagemagick libruby php7.2-curl php7.2-intl php7.2-pspell php7.2-recode php7.2-sqlite3 php7.2-tidy php7.2-xmlrpc php7.2-xsl memcached php-memcache php-imagick php-gettext php7.2-zip php7.2-mbstring php7.2-opcache php-apcu > /dev/null 2>&1
	
	sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php/7.2/fpm/php.ini
	sed -i "s/;date.timezone =/date.timezone=\"Europe\/Rome\"/" /etc/php/7.2/fpm/php.ini
	service php7.2-fpm reload
	echo -e "[${green}DONE${NC}]\n"
	
	apt-get -yqq install fcgiwrap
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
		echo "With nginx phpmyadmin is accessibile at  http://$CFG_HOSTNAME_FQDN:8081/phpmyadmin or http://IP_ADDRESS:8081/phpmyadmin"
		echo -e "[${green}DONE${NC}]\n"
	fi
	
  fi

  if [ "$CFG_XCACHE" == "yes" ]; then  
		echo -n "Installing XCache... "
		apt-get -yqq install php7-xcache > /dev/null 2>&1
		echo -e "[${green}DONE${NC}]\n"
  fi
  
  echo -n "Installing needed Programs for PHP and Apache... "
  apt-get -yqq install mcrypt imagemagick memcached curl tidy snmp redis-server > /dev/null 2>&1
  echo -e "[${green}DONE${NC}]\n"
 
  phpenmod mbstring

  echo -n "Installing Lets Encrypt... "	
  apt-get -yqq install letsencrypt
  echo -e "[${green}DONE${NC}]\n"
}
