#---------------------------------------------------------------------
# Function: InstallWebmail
#    Install the chosen webmail client. Squirrelmail or Roundcube
#---------------------------------------------------------------------
InstallWebmail() {
  echo -n "Installing webmail client ($CFG_WEBMAIL)... "
  case $CFG_WEBMAIL in
	"roundcube")
	#!/bin/bash

back_title="ISPConfig 3 Roundcube-CleanTheme Installer"

while [ "x$CFG_MYSQL_ROOT_PWD" == "x" ]
do
	MYSQL_PASSWORD=$(whiptail --title "MySQL Root Password" --backtitle "$back_title" --inputbox "Please insert the MySQL Root Password" --nocancel 10 50 3>&1 1>&2 2>&3)
done


#-- INSTALL Clean theme
cd /tmp
wget https://github.com/dclardy64/ISPConfig_Clean-3.0.5/archive/master.zip
unzip master.zip
cd ISPConfig_Clean-3.0.5-master
cp -R interface/* /usr/local/ispconfig/interface/

sed -i "s|\$conf\['theme'\] = 'default'|\$conf\['theme'\] = 'ispc-clean'|" /usr/local/ispconfig/interface/lib/config.inc.php
sed -i "s|\$conf\['logo'\] = 'themes/default|\$conf\['logo'\] = 'themes/ispc-clean|" /usr/local/ispconfig/interface/lib/config.inc.php

mysql -u root -p$CFG_MYSQL_ROOT_PWD < sql/ispc-clean.sql

#-- INSTALL roundbube

mkdir /opt/roundcube

wget https://downloads.sourceforge.net/project/roundcubemail/roundcubemail/1.1.3/roundcubemail-1.1.3-complete.tar.gz -P /opt/roundcube
tar xfz /opt/roundcube/roundcubemail-1.1.3-complete.tar.gz

mv /opt/roundcube/roundcubemail-1.1.3/* .
mv /opt/roundcube/roundcubemail-1.1.3/.htaccess .

rmdir /opt/roundcube/roundcubemail-1.1.3
rm /opt/roundcube/roundcubemail-1.1.3-complete.tar.gz

chown -R www-data:www-data /opt/roundcube

mysql --defaults-file=/etc/mysql/debian.cnf << END

CREATE DATABASE roundcubemail;
GRANT ALL PRIVILEGES ON roundcubemail.* TO roundcube@localhost IDENTIFIED BY '$CFG_MYSQL_ROOT_PWD';
flush privileges;
quit

END

mysql --defaults-file=/etc/mysql/debian.cnf roundcubemail < /opt/roundcube/SQL/mysql.initial.sql

cat > /opt/roundcube/config/config.inc.php << END

<?php

$config = array();
$config['db_dsnw'] = 'mysql://roundcube:$CFG_MYSQL_ROOT_PWD@localhost/roundcubemail';
$config['default_host'] = 'localhost';
$config['smtp_server'] = '';
$config['smtp_port'] = 25;
$config['smtp_user'] = '';
$config['smtp_pass'] = '';
$config['support_url'] = '';
$config['product_name'] = 'Roundcube Webmail';
$config['des_key'] = 'rcmail-!24ByteDESkey*Str';
$config['plugins'] = array(
    'archive',
    'zipdownload',
);
$config['skin'] = 'larry';

END

cat >  /etc/apache2/conf-available/roundcube.conf << END

Alias /roundcube /opt/roundcube
Alias /webmail /opt/roundcube

<Directory /opt/roundcube>
 Options +FollowSymLinks
 # AddDefaultCharset UTF-8
 AddType text/x-component .htc
 
 <IfModule mod_php5.c>
 AddType application/x-httpd-php .php
 php_flag display_errors Off
 php_flag log_errors On
 # php_value error_log logs/errors
 php_value upload_max_filesize 10M
 php_value post_max_size 12M
 php_value memory_limit 64M
 php_flag zlib.output_compression Off
 php_flag magic_quotes_gpc Off
 php_flag magic_quotes_runtime Off
 php_flag zend.ze1_compatibility_mode Off
 php_flag suhosin.session.encrypt Off
 #php_value session.cookie_path /
 php_flag session.auto_start Off
 php_value session.gc_maxlifetime 21600
 php_value session.gc_divisor 500
 php_value session.gc_probability 1
 </IfModule>

 <IfModule mod_rewrite.c>
 RewriteEngine On
 RewriteRule ^favicon\.ico$ skins/larry/images/favicon.ico
 # security rules:
 # - deny access to files not containing a dot or starting with a dot
 # in all locations except installer directory
 RewriteRule ^(?!installer)(\.?[^\.]+)$ - [F]
 # - deny access to some locations
 RewriteRule ^/?(\.git|\.tx|SQL|bin|config|logs|temp|tests|program\/(include|lib|localization|steps)) - [F]
 # - deny access to some documentation files
 RewriteRule /?(README\.md|composer\.json-dist|composer\.json|package\.xml)$ - [F]
 </IfModule>

 <IfModule mod_deflate.c>
 SetOutputFilter DEFLATE
 </IfModule>

 <IfModule mod_expires.c>
 ExpiresActive On
 ExpiresDefault "access plus 1 month"
 </IfModule>

 FileETag MTime Size

 <IfModule mod_autoindex.c>
 Options -Indexes
 </ifModule>

 AllowOverride None
 Require all granted
</Directory>

<Directory /opt/roundcube/plugins/enigma/home>
 Options -FollowSymLinks
 AllowOverride None
 Require all denied
</Directory>

<Directory /opt/roundcube/config>
 Options -FollowSymLinks
 AllowOverride None
 Require all denied
</Directory>

<Directory /opt/roundcube/temp>
 Options -FollowSymLinks
 AllowOverride None
 Require all denied
</Directory>

<Directory /opt/roundcube/logs>
 Options -FollowSymLinks
 AllowOverride None
 Require all denied
</Directory>

END

a2enconf roundcube
if [ $CFG_WEBSERVER == "apache" ]; then
	  service apache2 restart > /dev/null 2>&1
else
  service nginx restart > /dev/null 2>&1
fi
echo -e "[${green}DONE${NC}]\n"

  ;;
	"squirrelmail")	
  echo "dictionaries-common dictionaries-common/default-wordlist select american (American English)" | debconf-set-selections
  apt-get -yqq install squirrelmail wamerican > /dev/null 2>&1
  ln -s /etc/squirrelmail/apache.conf /etc/apache2/conf-enabled/squirrelmail
  sed -i 1d /etc/squirrelmail/apache.conf
  sed -i '1iAlias /webmail /usr/share/squirrelmail' /etc/squirrelmail/apache.conf

	case $CFG_MTA in
		"courier")
		  sed -i 's/$imap_server_type       = "other";/$imap_server_type       = "courier";/' /etc/squirrelmail/config.php
		  sed -i 's/$optional_delimiter     = "detect";/$optional_delimiter     = ".";/' /etc/squirrelmail/config.php
		  sed -i 's/$default_folder_prefix          = "";/$default_folder_prefix          = "INBOX.";/' /etc/squirrelmail/config.php
		  sed -i 's/$trash_folder                   = "INBOX.Trash";/$trash_folder                   = "Trash";/' /etc/squirrelmail/config.php
		  sed -i 's/$sent_folder                    = "INBOX.Sent";/$sent_folder                    = "Sent";/' /etc/squirrelmail/config.php
		  sed -i 's/$draft_folder                   = "INBOX.Drafts";/$draft_folder                   = "Drafts";/' /etc/squirrelmail/config.php
		  sed -i 's/$default_sub_of_inbox           = true;/$default_sub_of_inbox           = false;/' /etc/squirrelmail/config.php
		  sed -i 's/$delete_folder                  = false;/$delete_folder                  = true;/' /etc/squirrelmail/config.php
		  ;;
		"dovecot")
		  sed -i 's/$imap_server_type       = "other";/$imap_server_type       = "dovecot";/' /etc/squirrelmail/config.php
		  sed -i 's/$trash_folder                   = "INBOX.Trash";/$trash_folder                   = "Trash";/' /etc/squirrelmail/config.php
		  sed -i 's/$sent_folder                    = "INBOX.Sent";/$sent_folder                    = "Sent";/' /etc/squirrelmail/config.php
		  sed -i 's/$draft_folder                   = "INBOX.Drafts";/$draft_folder                   = "Drafts";/' /etc/squirrelmail/config.php
		  sed -i 's/$default_sub_of_inbox           = true;/$default_sub_of_inbox           = false;/' /etc/squirrelmail/config.php
		  sed -i 's/$delete_folder                  = false;/$delete_folder                  = true;/' /etc/squirrelmail/config.php
		  ;;
	  esac
  mkdir /var/lib/squirrelmail/tmp
  chown www-data /var/lib/squirrelmail/tmp
  if [ $CFG_WEBSERVER == "apache" ]; then
	  service apache2 restart > /dev/null 2>&1
  else
	  service nginx restart > /dev/null 2>&1
  fi
  echo -e "[${green}DONE${NC}]\n"
}

