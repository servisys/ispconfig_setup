#---------------------------------------------------------------------
# Function: InstallWebServer
#    Install and configure Apache2, php + modules
#---------------------------------------------------------------------
InstallWebServer() {
  echo "==========================================================================================="
  echo "Attention: When asked 'Configure database for phpmyadmin with dbconfig-common?' select 'NO'"
  echo "Due to a bug in dbconfig-common, this can't be automated."
  echo "==========================================================================================="
  echo "Press ENTER to continue... "
  read DUMMY

  if [ $CFG_WEBSERVER == "apache" ]; then
	echo "Installing Apache and Modules... "
	echo "phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2" | debconf-set-selections
	# - DISABLED DUE TO A BUG IN DBCONFIG - echo "phpmyadmin phpmyadmin/dbconfig-install boolean false" | debconf-set-selections
	echo "dbconfig-common dbconfig-common/dbconfig-install boolean false" | debconf-set-selections
	apt-get -y install apache2 apache2.2-common apache2-doc apache2-mpm-prefork apache2-utils libexpat1 ssl-cert libapache2-mod-php5 libapache2-mod-fastcgi libapache2-mod-fcgid apache2-suexec libapache2-mod-suphp libruby libapache2-mod-ruby libapache2-mod-python > /dev/null 2>&1  
	echo -e "${green}done!${NC}\n"
	echo "Installing PHP and Modules... "
	apt-get -y install php5 php5-common php5-dev php5-gd php5-mysqlnd php5-imap php5-cli php5-cgi php-pear php-auth php5-fpm php5-mcrypt php5-imagick php5-curl php5-intl php5-memcached php5-pspell php5-recode php5-snmp php5-sqlite php5-tidy php5-xmlrpc php5-xsl > /dev/null 2>&1 
	echo -e "${green}done!${NC}\n"
	echo "Installing needed Programs for PHP and Apache... "
	apt-get -y install mcrypt imagemagick memcached curl tidy> /dev/null 2>&1
    echo -e "${green}done!${NC}\n"	
	echo "Installing phpMyAdmin... "
	apt-get -qqy install phpmyadmin
	echo -e "${green}done!${NC}\n"
		
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
	service apache2 restart > /dev/null 2>&1
	sed -i "s/<FilesMatch \"\\\.ph(p3?|tml)\$\">/#<FilesMatch \"\\\.ph(p3?|tml)\$\">/" /etc/apache2/mods-available/suphp.conf
	sed -i "s/    SetHandler application\/x-httpd-suphp/#    SetHandler application\/x-httpd-suphp/" /etc/apache2/mods-available/suphp.conf
	sed -i "s/<\/FilesMatch>/#<\/FilesMatch>/" /etc/apache2/mods-available/suphp.conf
	sed -i "s/#<\/FilesMatch>/#<\/FilesMatch>\\`echo -e '\n\r'`        AddType application\/x-httpd-suphp .php .php3 .php4 .php5 .phtml/" /etc/apache2/mods-available/suphp.conf
	#sed -i "s/#/;/" /etc/php5/conf.d/ming.ini # Removed, because not longer present in php 5.6
	echo -e "${green}done! ${NC}\n"
  else
	service apache2 stop
	update-rc.d -f apache2 remove
	apt-get -y install nginx
	service nginx start
	apt-get -y install php5-fpm php5-mysqlnd php5-curl php5-gd php5-intl php-pear php5-imagick php5-imap php5-mcrypt php5-memcache php5-memcached php5-ming php5-ps php5-pspell php5-recode php5-snmp php5-sqlite php5-tidy php5-xmlrpc php5-xsl memcached php-apc
	sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php5/fpm/php.ini
	sed -i "s/;date.timezone =/date.timezone=\"Europe\/Rome\"/" /etc/php5/fpm/php.ini
	#sed -i "s/#/;/" /etc/php5/conf.d/ming.ini
	service php5-fpm reload
	apt-get -y install fcgiwrap
	echo "phpmyadmin phpmyadmin/reconfigure-webserver multiselect none" | debconf-set-selections
        # - DISABLED DUE TO A BUG IN DBCONFIG - echo "phpmyadmin phpmyadmin/dbconfig-install boolean false" | debconf-set-selections
    	echo "dbconfig-common dbconfig-common/dbconfig-install boolean false" | debconf-set-selections
	apt-get -qqy install phpmyadmin
    	echo "With nginx phpmyadmin is accessibile at  http://$CFG_HOSTNAME_FQDN:8081/phpmyadmin or http://IP_ADDRESS:8081/phpmyadmin"
  fi
  echo -e "${green}done! ${NC}\n"
}
