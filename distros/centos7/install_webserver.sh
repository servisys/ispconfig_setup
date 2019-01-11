#---------------------------------------------------------------------
# Function: InstallWebServer
#    Install and configure Apache2, php + modules
#---------------------------------------------------------------------
InstallWebServer() {

  if [ "$CFG_WEBSERVER" == "apache" ]; then
	CFG_NGINX=n
	CFG_APACHE=y
    echo -n "Installing Web server (Apache)... "
    yum -y install httpd mod_ssl
	echo -e "[${green}DONE${NC}]\n"
	echo -n "Installing PHP and modules... "
	yum -y install php php-mysql php-mbstring
	yum -y install php-devel php-gd php-imap php-ldap php-mysql php-odbc php-pear php-xml php-xmlrpc php-pecl-apc php-mbstring php-mcrypt php-mssql php-snmp php-soap php-tidy
	echo -n "Installing needed programs for PHP and Apache... "
	yum -y install curl curl-devel perl-libwww-perl ImageMagick libxml2 libxml2-devel mod_fcgid php-cli httpd-devel php-fpm wget
	echo -e "[${green}DONE${NC}]\n"
	sed -i "s/error_reporting = E_ALL \& ~E_DEPRECATED \& ~E_STRICT/error_reporting = E_ALL \& ~E_NOTICE \& ~E_DEPRECATED/" /etc/php.ini
	sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=1/" /etc/php.ini
	TIME_ZONE=$(echo "$TIME_ZONE" | sed -n 's/ (.*)$//p')
	sed -i "s/;date.timezone =/date.timezone=\"${TIME_ZONE//\//\\/}\"/" /etc/php.ini
	cd /usr/local/src
	yum -y install apr-devel
	wget -q http://suphp.org/download/suphp-0.7.2.tar.gz
	tar zxvf suphp-0.7.2.tar.gz
	wget -O suphp.patch https://raw.githubusercontent.com/b1glord/ispconfig_setup_extra/master/suphp.patch
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
	echo "x-httpd-suphp=\"php:/usr/bin/php-cgi\"" >> /etc/suphp.conf
	echo ";Handler for CGI-scripts" >> /etc/suphp.conf
	echo "x-suphp-cgi=\"execute:"'!'"self\"" >> /etc/suphp.conf
	
	sed -i '0,/<FilesMatch \\.php$>/ s/<FilesMatch \\.php$>/<Directory \/usr\/share>\n<FilesMatch \\.php$>/' /etc/httpd/conf.d/php.conf
	sed -i '0,/<\/FilesMatch>/ s/<\/FilesMatch>/<\/FilesMatch>\n<\/Directory>/' /etc/httpd/conf.d/php.conf
	
    systemctl start php-fpm.service
    systemctl enable php-fpm.service
    systemctl enable httpd.service
	
	#removed python support for now
	echo -n "Installing mod_python... "
	yum -y install python-devel
	cd /usr/local/src/
	wget -q http://dist.modpython.org/dist/mod_python-3.5.0.tgz
	tar xfz mod_python-3.5.0.tgz
	cd mod_python-3.5.0
	./configure
	make
	sed -e 's/(git describe --always)/(git describe --always 2>\/dev\/null)/g' -e 's/`git describe --always`/`git describe --always 2>\/dev\/null`/g' -i $( find . -type f -name Makefile\* -o -name version.sh )
	make install
	echo 'LoadModule python_module modules/mod_python.so' > /etc/httpd/conf.modules.d/10-python.conf
	echo -e "[${green}DONE${NC}]\n"
	echo "Installing phpMyAdmin... "
	yum -y install phpmyadmin
	echo -e "[${green}DONE${NC}]\n"
   	sed -i "s/Require ip 127.0.0.1/#Require ip 127.0.0.1/" /etc/httpd/conf.d/phpMyAdmin.conf
    	sed -i '0,/Require ip ::1/ s/Require ip ::1/#Require ip ::1\n       Require all granted/' /etc/httpd/conf.d/phpMyAdmin.conf
	sed -i "s/'cookie'/'http'/" /etc/phpMyAdmin/config.inc.php
    systemctl enable  httpd.service
    systemctl restart  httpd.service
	# echo -e "${green}done! ${NC}\n"
	
#https://www.howtoforge.com/tutorial/how-to-install-wordpress-with-hhvm-and-nginx-on-centos-7/#step-configure-hhvm-and-nginx
#http://mirrors.linuxeye.com/hhvm-repo/7/x86_64/

 echo -n "Installing Hhvm (Apache)... "
 hide_output yum install -y cpp gcc-c++ cmake psmisc {binutils,boost,jemalloc,numactl}-devel \
 {ImageMagick,sqlite,tbb,bzip2,openldap,readline,elfutils-libelf,gmp,lz4,pcre}-devel \
 lib{xslt,event,yaml,vpx,png,zip,icu,mcrypt,memcached,cap,dwarf}-devel \
 {unixODBC,expat,mariadb}-devel lib{edit,curl,xml2,xslt}-devel \
 glog-devel oniguruma-devel ocaml gperf enca libjpeg-turbo-devel openssl-devel \
 mariadb mariadb-server libc-client make

 hide_output rpm -Uvh http://mirrors.linuxeye.com/hhvm-repo/7/x86_64/hhvm-3.15.3-1.el7.centos.x86_64.rpm
 ln -s /usr/local/bin/hhvm /bin/hhvm

 echo "[Unit]" >> /etc/systemd/system/hhvm.service
 echo "Description=HHVM HipHop Virtual Machine (FCGI)" >> /etc/systemd/system/hhvm.service
 echo "After=network.target nginx.service mariadb.service" >> /etc/systemd/system/hhvm.service
 echo "" >> /etc/systemd/system/hhvm.service
 echo "[Service]" >> /etc/systemd/system/hhvm.service
 echo "ExecStart=/usr/local/bin/hhvm --config /etc/hhvm/server.ini --user nginx --mode daemon -vServer.Type=fastcgi -  vServer.FileSocket=/var/run/hhvm/hhvm.sock" >> /etc/systemd/system/hhvm.service
 echo "" >> /etc/systemd/system/hhvm.service
 echo "[Install]" >> /etc/systemd/system/hhvm.service
 echo "WantedBy=multi-user.target" >> /etc/systemd/system/hhvm.service

 hhvm --version
 echo -e "[${green}DONE${NC}]\n"
	
elif [ "$CFG_WEBSERVER" == "nginx" ]; then
	CFG_NGINX=y
	CFG_APACHE=n
    echo -n "Installing Web server (nginx)... "
    yum -y install nginx
	echo -e "[${green}DONE${NC}]\n"
	echo -n "Installing PHP and modules... "
	yum -y install php php-mysql php-mbstring
	yum -y install php-devel php-gd php-imap php-ldap php-mysql php-odbc php-pear php-xml php-xmlrpc php-pecl-apc php-mbstring php-mcrypt php-mssql php-snmp php-soap php-tidy
    echo -n "Installing needed programs for PHP and Apache... "
	yum -y install curl curl-devel perl-libwww-perl ImageMagick libxml2 libxml2-devel mod_fcgid php-cli httpd-devel php-fpm wget
	echo -e "[${green}DONE${NC}]\n"
	sed -i "s/error_reporting = E_ALL \& ~E_DEPRECATED \& ~E_STRICT/error_reporting = E_ALL \& ~E_NOTICE \& ~E_DEPRECATED/" /etc/php.ini
	sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=1/" /etc/php.ini
	TIME_ZONE=$(echo "$TIME_ZONE" | sed -n 's/ (.*)$//p')
	sed -i "s/;date.timezone =/date.timezone=\"${TIME_ZONE//\//\\/}\"/" /etc/php.ini
   systemctl start php-fpm.service
   systemctl enable php-fpm.service
   systemctl enable nginx.service

#https://www.howtoforge.com/tutorial/how-to-install-wordpress-with-hhvm-and-nginx-on-centos-7/#step-configure-hhvm-and-nginx
#http://mirrors.linuxeye.com/hhvm-repo/7/x86_64/

 echo -n "Installing Hhvm (nginx)... "
 hide_output yum install -y cpp gcc-c++ cmake psmisc {binutils,boost,jemalloc,numactl}-devel \
 {ImageMagick,sqlite,tbb,bzip2,openldap,readline,elfutils-libelf,gmp,lz4,pcre}-devel \
 lib{xslt,event,yaml,vpx,png,zip,icu,mcrypt,memcached,cap,dwarf}-devel \
 {unixODBC,expat,mariadb}-devel lib{edit,curl,xml2,xslt}-devel \
 glog-devel oniguruma-devel ocaml gperf enca libjpeg-turbo-devel openssl-devel \
 mariadb mariadb-server libc-client make

 hide_output rpm -Uvh http://mirrors.linuxeye.com/hhvm-repo/7/x86_64/hhvm-3.15.3-1.el7.centos.x86_64.rpm
 ln -s /usr/local/bin/hhvm /bin/hhvm

 echo "[Unit]" >> /etc/systemd/system/hhvm.service
 echo "Description=HHVM HipHop Virtual Machine (FCGI)" >> /etc/systemd/system/hhvm.service
 echo "After=network.target nginx.service mariadb.service" >> /etc/systemd/system/hhvm.service
 echo "" >> /etc/systemd/system/hhvm.service
 echo "[Service]" >> /etc/systemd/system/hhvm.service
 echo "ExecStart=/usr/local/bin/hhvm --config /etc/hhvm/server.ini --user nginx --mode daemon -vServer.Type=fastcgi -  vServer.FileSocket=/var/run/hhvm/hhvm.sock" >> /etc/systemd/system/hhvm.service
 echo "" >> /etc/systemd/system/hhvm.service
 echo "[Install]" >> /etc/systemd/system/hhvm.service
 echo "WantedBy=multi-user.target" >> /etc/systemd/system/hhvm.service

 hhvm --version
 echo -e "[${green}DONE${NC}]\n"
 fi

  echo -e "${green}done! ${NC}\n"

  echo -n "Installing Let's Encrypt (Certbot)... "
  yum -y install certbot

  echo -e "[${green}DONE${NC}]\n"
}
