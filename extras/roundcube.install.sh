###############################################################################################
# Complete ISPConfig setup script for Debian/Ubuntu Systems         			                    #
# Drew Clardy										                                                              # 
# http://drewclardy.com				                                                                #
# http://github.com/dclardy64/ISPConfig-3-Debian-Install                                      #
###############################################################################################

back_title="ISPConfig 3 RoundCube Installer"

roundcube_questions (){
  while [ "x$web_server" == "x" ]
  do
    web_server=$(whiptail --title "Web Server" --backtitle "$back_title" --nocancel --radiolist "Select Web Server Software" 10 50 2 "Apache" "(default)" ON "NginX" "" OFF 3>&1 1>&2 2>&3)
  done
  while [ "x$mysql_pass" == "x" ]
  do
    mysql_pass=$(whiptail --title "MySQL Root Password" --backtitle "$back_title" --inputbox "Please specify a MySQL Root Password" --nocancel 10 50 3>&1 1>&2 2>&3)
  done
  if [ $web_server == "NginX" ]; then
    while [ "x$roundcube_db" == "x" ]
    do
      roundcube_db=$(whiptail --title "MySQL Root Password" --backtitle "$back_title" --inputbox "Please specify a RoundCube Database" --nocancel 10 50 3>&1 1>&2 2>&3)
    done
    while [ "x$roundcube_user" == "x" ]
    do
      roundcube_user=$(whiptail --title "MySQL Root Password" --backtitle "$back_title" --inputbox "Please specify a RoundCube User" --nocancel 10 50 3>&1 1>&2 2>&3)
    done
    while [ "x$roundcube_pass" == "x" ]
    do
      roundcube_pass=$(whiptail --title "MySQL Root Password" --backtitle "$back_title" --inputbox "Please specify a RoundCube User Password" --nocancel 10 50 3>&1 1>&2 2>&3)
    done
  fi
}

RoundCube_install_Apache() {

echo "roundcube-core  roundcube/language      select  en_US" | debconf-set-selections
echo "roundcube-core  roundcube/database-type select  mysql" | debconf-set-selections
echo "roundcube-core  roundcube/mysql/admin-pass      $mysql_pass" | debconf-set-selections
echo "roundcube-core  roundcube/dbconfig-install      boolean true" | debconf-set-selections

apt-get install -y roundcube roundcube-plugins roundcube-plugins-extra
apt-get remove -y --purge squirrelmail

mv /etc/apache2/conf.d/roundcube /etc/apache2/conf.d/roundcube.backup
cat > /etc/apache2/conf.d/roundcube <<"EOF"
# Those aliases do not work properly with several hosts on your apache server
# Uncomment them to use it or adapt them to your configuration
Alias /roundcube/program/js/tiny_mce/ /usr/share/tinymce/www/
Alias /roundcube /var/lib/roundcube
Alias /webmail /var/lib/roundcube

# Access to tinymce files
<Directory "/usr/share/tinymce/www/">
      Options Indexes MultiViews FollowSymLinks
      AllowOverride None
      Order allow,deny
      allow from all
</Directory>

<Directory /var/lib/roundcube/>
  Options +FollowSymLinks
  DirectoryIndex index.php

  <IfModule mod_php5.c>
    AddType application/x-httpd-php .php

    php_flag magic_quotes_gpc Off
    php_flag track_vars On
    php_flag register_globals Off
    php_value include_path .:/usr/share/php
  </IfModule>

  # This is needed to parse /var/lib/roundcube/.htaccess. See its
  # content before setting AllowOverride to None.
  AllowOverride All
  order allow,deny
  allow from all
</Directory>

# Protecting basic directories:
<Directory /var/lib/roundcube/config>
        Options -FollowSymLinks
        AllowOverride None
</Directory>

<Directory /var/lib/roundcube/temp>
        Options -FollowSymLinks
        AllowOverride None
        Order allow,deny
        Deny from all
</Directory>

<Directory /var/lib/roundcube/logs>
        Options -FollowSymLinks
        AllowOverride None
        Order allow,deny
        Deny from all
</Directory>
EOF

rm /etc/apache2/conf.d/squirrelmail.conf
/etc/init.d/apache2 restart

sed -i "s|^\(\$rcmail_config\['default_host'\] =\).*$|\1 \'%s\';|" /etc/roundcube/main.inc.php
sed -i "s|^\(\$rcmail_config\['smtp_server'\] =\).*$|\1 \'%h\';|" /etc/roundcube/main.inc.php
sed -i "s|^\(\$rcmail_config\['smtp_user'\] =\).*$|\1 \'%u\';|" /etc/roundcube/main.inc.php
sed -i "s|^\(\$rcmail_config\['smtp_pass'\] =\).*$|\1 \'%p\';|" /etc/roundcube/main.inc.php

}

RoundCube_install_NginX() {

#Make RoundCube Directory
mkdir -p /var/www/roundcube 

#RoundCube Download
cd /tmp
wget http://downloads.sourceforge.net/project/roundcubemail/roundcubemail/1.0.4/roundcubemail-1.0.4.tar.gz
tar xvfz roundcubemail-1.0.4.tar.gz
cd roundcubemail-1.0.4/
mv * /var/www/roundcube/

chown -R ispapps:ispapps /var/www/roundcube

mysql -uroot -p$mysql_pass -e "CREATE DATABASE $roundcube_db;"
mysql -uroot -p$mysql_pass -e "GRANT ALL PRIVILEGES ON $roundcube_db.* TO '$roundcube_user'@'localhost' IDENTIFIED BY '$roundcube_pass';"
mysql -uroot -p$mysql_pass -e "GRANT ALL PRIVILEGES ON $roundcube_db.* TO '$roundcube_user'@'localhost.localdomain' IDENTIFIED BY '$roundcube_pass';"
mysql -uroot -p$mysql_pass -e "FLUSH PRIVILEGES;"

mysql -uroot -p$mysql_pass "$roundcube_db" < /var/www/roundcube/SQL/mysql.initial.sql

cat > /etc/nginx/sites-available/webmail.vhost <<"EOF"
  server {
      listen 80;
      server_name webmail.*;

      index index.php index.html;
      root /var/www/roundcube;

      location ~ ^/favicon.ico$ {
    	root /var/www/roundcube/skins/default/images;
        log_not_found off;
        access_log off;
        expires max;
      }

      location = /robots.txt {
          allow all;
          log_not_found off;
          access_log off;
      } 

      location ~ ^/(README|INSTALL|LICENSE|CHANGELOG|UPGRADING)$ {
          deny all;
      }

      location ~ ^/(bin|SQL)/ {
          deny all;
      }

      location ~ /\. {
          deny all;
          access_log off;
          log_not_found off;
      }

      location ~ \.php$ {
          try_files $uri =404;
          include /etc/nginx/fastcgi_params;
          fastcgi_pass unix://var/lib/php5-fpm/apps.sock;
          fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
          fastcgi_index index.php;
      }
}
EOF

cd /etc/nginx/sites-enabled/
ln -s /etc/nginx/sites-available/webmail.vhost webmail.vhost

/etc/init.d/nginx reload

cd /var/www/roundcube/config
mv config.inc.php.sample config.inc.php

sed -i "s|mysql://roundcube:pass@localhost/roundcubemail|mysqli://$roundcube_user:$roundcube_pass@localhost/$roundcube_db|" /var/www/roundcube/config/config.inc.php

sed -i "s|^\(\$config\['default_host'\] =\).*$|\1 \'%s\';|" /var/www/roundcube/config/config.inc.php
sed -i "s|^\(\$config\['smtp_server'\] =\).*$|\1 \'%h\';|" /var/www/roundcube/config/config.inc.php
sed -i "s|^\(\$config\['smtp_user'\] =\).*$|\1 \'%u\';|" /var/www/roundcube/config/config.inc.php
sed -i "s|^\(\$config\['smtp_pass'\] =\).*$|\1 \'%p\';|" /var/www/roundcube/config/config.inc.php

rm -rf /var/www/roundcube/installer
}
