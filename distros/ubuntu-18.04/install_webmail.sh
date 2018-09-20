#---------------------------------------------------------------------
# Function: InstallWebmail
#    Install the chosen webmail client. Roundcube
#---------------------------------------------------------------------
InstallWebmail() {
	  echo -n "Installing Webmail client (Roundcube)... "
	  CFG_ROUNDCUBE_PWD=$(< /dev/urandom tr -dc A-Z-a-z-0-9 | head -c12)
	  echo "roundcube-core roundcube/dbconfig-install boolean true" | debconf-set-selections
	  echo "roundcube-core roundcube/database-type select mysql" | debconf-set-selections
	  echo "roundcube-core roundcube/mysql/admin-pass password $CFG_MYSQL_ROOT_PWD" | debconf-set-selections
	  echo "roundcube-core roundcube/db/dbname string roundcube" | debconf-set-selections
	  echo "roundcube-core roundcube/mysql/app-pass password $CFG_ROUNDCUBE_PWD" | debconf-set-selections
	  echo "roundcube-core roundcube/app-password-confirm password $CFG_ROUNDCUBE_PWD" | debconf-set-selections
	  echo "roundcube-core roundcube/hosts string localhost" | debconf-set-selections
	  apt_install roundcube roundcube-core roundcube-mysql roundcube-plugins javascript-common libjs-jquery-mousewheel php-net-sieve tinymce
	  sed -i "s/\$config\['default_host'\] = '';/\$config['default_host'] = 'localhost';/" /etc/roundcube/config.inc.php
	  if [ "$CFG_WEBSERVER" == "apache" ]; then
		echo "Alias /webmail /var/lib/roundcube" >> /etc/apache2/conf-enabled/roundcube.conf
		echo "Alias /roundcube /var/lib/roundcube" >> /etc/apache2/conf-enabled/roundcube.conf
		service apache2 reload
	  elif [ "$CFG_WEBSERVER" == "nginx" ]; then
        cat << "EOF" > /etc/nginx/sites-available/roundcube.vhost
server {
   # SSL configuration
   listen 443 ssl;

   ssl on;
   ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
   ssl_certificate /usr/local/ispconfig/interface/ssl/ispserver.crt;
   ssl_certificate_key /usr/local/ispconfig/interface/ssl/ispserver.key;

   location /roundcube {
      root /var/lib/;
      index index.php index.html index.htm;
      location ~ ^/roundcube/(.+\.php)$ {
        try_files $uri =404;
        root /var/lib/;
        include /etc/nginx/fastcgi_params;
        # To access SquirrelMail, the default user (like www-data on Debian/Ubuntu) mu$
        #fastcgi_pass 127.0.0.1:9000;
        fastcgi_pass unix:/var/run/php/php7.0-fpm.sock;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        fastcgi_buffer_size 128k;
        fastcgi_buffers 256 4k;
        fastcgi_busy_buffers_size 256k;
        fastcgi_temp_file_write_size 256k;
      }
      location ~* ^/roundcube/(.+\.(jpg|jpeg|gif|css|png|js|ico|html|xml|txt))$ {
        root /var/lib/;
      }
      location ~* /.svn/ {
        deny all;
      }
      location ~* /README|INSTALL|LICENSE|SQL|bin|CHANGELOG$ {
        deny all;
      }
   }
   location /webmail {
     rewrite ^/* /roundcube last;
   }
}
EOF
		ln -s /etc/nginx/sites-available/roundcube.vhost /etc/nginx/sites-enabled/roundcube.vhost
	  fi
  echo -e "[${green}DONE${NC}]\n"
  if [ "$CFG_WEBSERVER" == "apache" ]; then
	  echo -n "Restarting Apache... "
	  service apache2 restart
  elif [ "$CFG_WEBSERVER" == "nginx" ]; then
	  echo -n "Restarting nginx... "
	  service nginx restart
  fi
  echo -e "[${green}DONE${NC}]\n"
}

