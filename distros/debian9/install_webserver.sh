#---------------------------------------------------------------------
# Function: InstallWebServer Debian 8
#    Install and configure Apache2, php + modules
#---------------------------------------------------------------------
InstallWebServer() {
  
  if [ $CFG_WEBSERVER == "apache" ]; then
  CFG_NGINX=n
  CFG_APACHE=y
  echo -n "Installing Apache and Modules... "
	echo "phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2" | debconf-set-selections
	# - DISABLED DUE TO A BUG IN DBCONFIG - echo "phpmyadmin phpmyadmin/dbconfig-install boolean false" | debconf-set-selections
	echo "dbconfig-common dbconfig-common/dbconfig-install boolean false" | debconf-set-selections
	apt-get -yqq install apache2 apache2-doc apache2-utils libapache2-mod-php  libapache2-mod-fcgid apache2-suexec-pristine libruby libapache2-mod-python php-memcache php-imagick php-gettext  libapache2-mod-passenger  > /dev/null 2>&1
	echo -e "[${green}DONE${NC}]\n"
	echo -n "Installing PHP and Modules... "
	apt-get -yqq install php7.0 php7.0-common php7.0-gd php7.0-mysql php7.0-imap phpmyadmin php7.0-cli php7.0-cgi php-pear php7.0-mcrypt php7.0-curl php7.0-intl php7.0-pspell php7.0-recode php7.0-sqlite3 php7.0-tidy php7.0-xmlrpc php7.0-xsl php7.0-zip php7.0-mbstring php7.0-imap php7.0-mcrypt php7.0-snmp php7.0-xmlrpc php7.0-xsl  > /dev/null 2>&1
	echo -e "[${green}DONE${NC}]\n"
	echo -n "Installing PHP-FPM"
	apt-get -yqq php7.0-fpm
	a2enmod actions > /dev/null 2>&1 
	a2enmod proxy_fcgi > /dev/null 2>&1 
	a2enmod alias > /dev/null 2>&1 
	echo -e "[${green}DONE${NC}]\n"
	echo -n "Installing needed Programs for PHP and Apache... "
	apt-get -yqq install mcrypt imagemagick memcached curl tidy snmp > /dev/null 2>&1
    	echo -e "[${green}DONE${NC}]\n"
	
  if [ $CFG_PHPMYADMIN == "yes" ]; then
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
	apt-get -yqq install php5-xcache > /dev/null 2>&1
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
	a2enmod cgi > /dev/null 2>&1
	a2enmod headers > /dev/null 2>&1
	
	echo -n "Disable HTTP_PROXY"
	echo "<IfModule mod_headers.c>" >> /etc/apache2/conf-available/httpoxy.conf
	echo "     RequestHeader unset Proxy early" >> /etc/apache2/conf-available/httpoxy.conf
	echo "</IfModule>" >> /etc/apache2/conf-available/httpoxy.conf
	a2enconf httpoxy > /dev/null 2>&1
	service apache2 restart > /dev/null 2>&1
	echo -e "[${green}DONE${NC}]\n"
	
	echo -n "Installing Lets Encrypt... "	
	apt-get -yqq apt-get install certbot
	echo -e "[${green}DONE${NC}]\n"
  
    echo -n "Install PHP Opcode Cache "	
    apt-get -y install php7.0-opcache php-apcu
	service apache2 restart
	echo -e "[${green}DONE${NC}]\n"
  else
	
  CFG_NGINX=y
  CFG_APACHE=n
	echo -n "Installing NGINX and Modules... "
	service apache2 stop
	update-rc.d -f apache2 remove
	apt-get -yqq install nginx > /dev/null 2>&1
	service nginx start 
	apt-get -yqq install php5-fpm php5-mysqlnd php5-curl php5-gd php5-intl php-pear php5-imagick php5-imap php5-mcrypt php5-memcache php5-memcached php5-pspell php5-recode php5-snmp php5-sqlite php5-tidy php5-xmlrpc php5-xsl memcached php-apc > /dev/null 2>&1
	sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php5/fpm/php.ini
	sed -i "s/;date.timezone =/date.timezone=\"Europe\/Rome\"/" /etc/php5/fpm/php.ini
	echo -n "Installing needed Programs for PHP and NGINX... "
	apt-get -yqq install mcrypt imagemagick memcached curl tidy snmp > /dev/null 2>&1
	#sed -i "s/#/;/" /etc/php5/conf.d/ming.ini
	service php5-fpm reload
	apt-get -yqq install fcgiwrap
  
  if [ $CFG_PHPMYADMIN == "yes" ]; then
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
  
  	echo -n "Installing Lets Encrypt... "	
	apt-get -yqq install certbot -t jessie-backports
	certbot &
	echo -e "[${green}DONE${NC}]\n"
  
  fi
  echo -e "[${green}DONE${NC}]\n"
}
