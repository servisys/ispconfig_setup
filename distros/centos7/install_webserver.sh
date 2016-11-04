#---------------------------------------------------------------------
# Function: InstallWebServer
#    Install and configure Apache2, php + modules
#---------------------------------------------------------------------
InstallWebServer() {

  if [ $CFG_WEBSERVER == "apache" ]; then
    echo "Installing Apache and..."
    yum -y install httpd
	echo -e "${green}done!${NC}\n"
	echo "Installing PHP and Modules... "
	yum -y install mod_ssl php php-mysql php-mbstring php-devel php-gd php-imap php-ldap php-mysql php-odbc php-pear php-xml php-xmlrpc php-pecl-apc php-mbstring php-mcrypt php-mssql php-snmp php-soap php-tidy php-fpm httpd-devel > /dev/null 2>&1 
	echo "Installing needed Programs for PHP and Apache... "
	yum -y install curl curl-devel perl-libwww-perl ImageMagick libxml2 libxml2-devel mod_fcgid php-cli > /dev/null 2>&1
	echo -e "${green}done!${NC}\n"	
	sed -i "s/error_reporting = E_ALL \& ~E_DEPRECATED \& ~E_STRICT/error_reporting = E_ALL \& ~E_NOTICE \& ~E_DEPRECATED/" /etc/php.ini
	sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=1/" /etc/php.ini
	sed -i "s/;date.timezone =/date.timezone = 'Europe\/Berlin'/" /etc/php.ini
	cd /usr/local/src
	yum -y install apr-devel
	wget http://suphp.org/download/suphp-0.7.2.tar.gz
	tar zxvf suphp-0.7.2.tar.gz
	wget -O suphp.patch https://lists.marsching.com/pipermail/suphp/attachments/20130520/74f3ac02/attachment.patch
	patch -Np1 -d suphp-0.7.2 < suphp.patch
	cd suphp-0.7.2
	autoreconf -if
	./configure --prefix=/usr/ --sysconfdir=/etc/ --with-apr=/usr/bin/apr-1-config --with-apache-user=apache --with-setid-mode=owner --with-logfile=/var/log/httpd/suphp_log
    make
    make install
	echo "LoadModule suphp_module /usr/lib64/httpd/modules/mod_suphp.so" > /etc/httpd/conf.d/suphp.conf
	echo "[global]" > /etc/suphp.conf
	echo ";Path to logfile" >> /etc/suphp.conf 
	echo "logfile=/var/log/httpd/suphp.log" >> /etc/suphp.conf
	echo ";Loglevel" >> /etc/suphp.conf
	echo "loglevel=info" >> /etc/suphp.conf
	echo ";User Apache is running as" >> /etc/suphp.conf
	echo "webserver_user=apache" >> /etc/suphp.conf
	echo ";Path all scripts have to be in" >> /etc/suphp.conf
	echo "docroot=/" >> /etc/suphp.conf
	echo ";Path to chroot() to before executing script" >> /etc/suphp.conf
	echo ";chroot=/mychroot" >> /etc/suphp.conf
	echo "; Security options" >> /etc/suphp.conf
	echo "allow_file_group_writeable=true" >> /etc/suphp.conf
	echo "allow_file_others_writeable=false" >> /etc/suphp.conf
	echo "allow_directory_group_writeable=true" >> /etc/suphp.conf
	echo "allow_directory_others_writeable=false" >> /etc/suphp.conf
	echo ";Check wheter script is within DOCUMENT_ROOT" >> /etc/suphp.conf
	echo "check_vhost_docroot=true" >> /etc/suphp.conf
	echo ";Send minor error messages to browser" >> /etc/suphp.conf
	echo "errors_to_browser=false" >> /etc/suphp.conf
	echo ";PATH environment variable" >> /etc/suphp.conf
	echo "env_path=/bin:/usr/bin" >> /etc/suphp.conf
	echo ";Umask to set, specify in octal notation" >> /etc/suphp.conf
	echo "umask=0077" >> /etc/suphp.conf
	echo "; Minimum UID" >> /etc/suphp.conf
	echo "min_uid=100" >> /etc/suphp.conf
	echo "; Minimum GID" >> /etc/suphp.conf
	echo "min_gid=100" >> /etc/suphp.conf
	echo "" >> /etc/suphp.conf
	echo "[handlers]" >> /etc/suphp.conf
	echo ";Handler for php-scripts" >> /etc/suphp.conf
	echo "x-httpd-suphp="php:/usr/bin/php-cgi"" >> /etc/suphp.conf
	echo ";Handler for CGI-scripts" >> /etc/suphp.conf
	echo "x-suphp-cgi=\"execute:"'!'"self\"" >> /etc/suphp.conf
	
	sed -i '0,/<FilesMatch \\.php$>/ s/<FilesMatch \\.php$>/<Directory \/usr\/share>\n<FilesMatch \\.php$>/' /etc/httpd/conf.d/php.conf
	sed -i '0,/<\/FilesMatch>/ s/<\/FilesMatch>/<\/FilesMatch>\n<\/Directory>/' /etc/httpd/conf.d/php.conf
	
	systemctl start php-fpm.service
    systemctl enable php-fpm.service
    systemctl enable httpd.service
	
	#removed python support for now
	#yum -y install python-devel
	#cd /usr/local/src/
	#wget http://dist.modpython.org/dist/mod_python-3.5.0.tgz
	#tar xfz mod_python-3.5.0.tgz
	#cd mod_python-3.5.0
	#./configure
	#make
	#make install
	#echo 'LoadModule python_module modules/mod_python.so' > /etc/httpd/conf.modules.d/10-python.conf
	echo -e "${green}done!${NC}\n"
	echo "Installing phpMyAdmin... "
	yum -y install phpmyadmin
	echo -e "${green}done!${NC}\n"
    sed -i "s/Require ip 127.0.0.1/#Require ip 127.0.0.1/" /etc/httpd/conf.d/phpMyAdmin.conf
    sed -i '0,/Require ip ::1/ s/Require ip ::1/#Require ip ::1\n       Require all granted/' /etc/httpd/conf.d/phpMyAdmin.conf
	sed -i "s/'cookie'/'http'/" /etc/phpMyAdmin/config.inc.php
	echo "Installing Let's Encrypt... "
	yum -y install letsencrypt > /dev/null 2>&1
	echo -e "${green}done!${NC}\n"
	systemctl enable  httpd.service
    systemctl restart  httpd.service
	echo -e "${green}done! ${NC}\n"
  else
    echo "Sorry Nginx not implemented Yet"
	read DUMMY
  fi
  echo -e "${green}done! ${NC}\n"
}
