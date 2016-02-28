#---------------------------------------------------------------------
# Function: InstallWebmail
#    Install the chosen webmail client. Squirrelmail or Roundcube
#---------------------------------------------------------------------
InstallWebmail() {
  echo -n "Installing webmailcient ($CFG_WEBMAIL)... "
  case $CFG_WEBMAIL in
	"roundcube")
#    ROUNCUBE_VERSION="1.1.4"
    mkdir -p /var/www/roundcube

    cd /tmp
    wget https://downloads.sourceforge.net/project/roundcubemail/roundcubemail/1.1.3/roundcubemail-1.1.3-complete.tar.gz
    tar xfz roundcubemail-1.1.3-complete.tar.gz
    cd roundcubemail-1.1.3/
    mv * /var/www/roundcube
    
    chown -R ispapps:ispapps /var/www/roundcube

    mysql -uroot -p$CFG_MYSQL_ROOT_PWD -e "CREATE DATABASE $roundcube_db;"
    mysql -uroot -p$CFG_MYSQL_ROOT_PWD -e "GRANT ALL PRIVILEGES ON $roundcube_db.* TO '$roundcube_user'@'localhost' IDENTIFIED BY'$roundcube_pass';"
    mysql -uroot -p$CFG_MYSQL_ROOT_PWD -e "GRANT ALL PRIVILEGES ON $roundcube_db.* TO '$roundcube_user'@'localhost.localdomain' IDENTIFIED BY'$roundcube_pass';"
    mysql -uroot -p$CFG_MYSQL_ROOT_PWD -e "FLUSH PRIVILEGES;"

    mysql -uroot -p$CFG_MYSQL_ROOT_PWD "$roundcube_db" </var/www/roundcube/SQL/mysql.initial.sql
    if [ $CFG_WEBSERVER == "apache" ]; then
    mv /etc/apache2/conf.d/roundcube /etc/apache2/conf.d/roundcube.backup
        cat > /etc/apache2/conf.d/roundcube << "EOF"
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

	  else
		echo "  location /roundcube {" > /etc/nginx/roundcube.conf
		echo "          root /var/lib/;" >> /etc/nginx/roundcube.conf
		echo "           index index.php index.html index.htm;" >> /etc/nginx/roundcube.conf
		echo "           location ~ ^/roundcube/(.+\.php)\$ {" >> /etc/nginx/roundcube.conf
		echo "                   try_files \$uri =404;" >> /etc/nginx/roundcube.conf
		echo "                   root /var/lib/;" >> /etc/nginx/roundcube.conf
		echo "                   fastcgi_param   QUERY_STRING            \$query_string;" >> /etc/nginx/roundcube.conf
		echo "                   fastcgi_param   REQUEST_METHOD          \$request_method;" >> /etc/nginx/roundcube.conf
		echo "                   fastcgi_param   CONTENT_TYPE            \$content_type;" >> /etc/nginx/roundcube.conf
		echo "                   fastcgi_param   CONTENT_LENGTH          \$content_length;" >> /etc/nginx/roundcube.conf
		echo "                   fastcgi_param   SCRIPT_FILENAME         \$request_filename;" >> /etc/nginx/roundcube.conf
		echo "                   fastcgi_param   SCRIPT_NAME             \$fastcgi_script_name;" >> /etc/nginx/roundcube.conf
		echo "                   fastcgi_param   REQUEST_URI             \$request_uri;" >> /etc/nginx/roundcube.conf
		echo "                   fastcgi_param   DOCUMENT_URI            \$document_uri;" >> /etc/nginx/roundcube.conf
		echo "                   fastcgi_param   DOCUMENT_ROOT           \$document_root;" >> /etc/nginx/roundcube.conf
		echo "                   fastcgi_param   SERVER_PROTOCOL         \$server_protocol;" >> /etc/nginx/roundcube.conf
		echo "                   fastcgi_param   GATEWAY_INTERFACE       CGI/1.1;" >> /etc/nginx/roundcube.conf
		echo "                   fastcgi_param   SERVER_SOFTWARE         nginx/\$nginx_version;" >> /etc/nginx/roundcube.conf
		echo "                   fastcgi_param   REMOTE_ADDR             \$remote_addr;" >> /etc/nginx/roundcube.conf
		echo "                   fastcgi_param   REMOTE_PORT             \$remote_port;" >> /etc/nginx/roundcube.conf
		echo "                   fastcgi_param   SERVER_ADDR             \$server_addr;" >> /etc/nginx/roundcube.conf
		echo "                   fastcgi_param   SERVER_PORT             \$server_port;" >> /etc/nginx/roundcube.conf
		echo "                   fastcgi_param   SERVER_NAME             \$server_name;" >> /etc/nginx/roundcube.conf
		echo "                   fastcgi_param   HTTPS                   \$https;" >> /etc/nginx/roundcube.conf
		echo "                   # PHP only, required if PHP was built with --enable-force-cgi-redirect" >> /etc/nginx/roundcube.conf
		echo "                   fastcgi_param   REDIRECT_STATUS         200;" >> /etc/nginx/roundcube.conf
		echo "                   # To access SquirrelMail, the default user (like www-data on Debian/Ubuntu) mu\$" >> /etc/nginx/roundcube.conf
		echo "                   #fastcgi_pass 127.0.0.1:9000;" >> /etc/nginx/roundcube.conf
		echo "                   fastcgi_pass unix:/var/run/php5-fpm.sock;" >> /etc/nginx/roundcube.conf
		echo "                   fastcgi_index index.php;" >> /etc/nginx/roundcube.conf
		echo "                   fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;" >> /etc/nginx/roundcube.conf
		echo "                   fastcgi_buffer_size 128k;" >> /etc/nginx/roundcube.conf
		echo "                   fastcgi_buffers 256 4k;" >> /etc/nginx/roundcube.conf
		echo "                   fastcgi_busy_buffers_size 256k;" >> /etc/nginx/roundcube.conf
		echo "                   fastcgi_temp_file_write_size 256k;" >> /etc/nginx/roundcube.conf
		echo "           }" >> /etc/nginx/roundcube.conf
		echo "           location ~* ^/roundcube/(.+\.(jpg|jpeg|gif|css|png|js|ico|html|xml|txt))\$ {" >> /etc/nginx/roundcube.conf
		echo "                   root /var/lib/;" >> /etc/nginx/roundcube.conf
		echo "           }" >> /etc/nginx/roundcube.conf
		echo "           location ~* /.svn/ {" >> /etc/nginx/roundcube.conf
		echo "                   deny all;" >> /etc/nginx/roundcube.conf
		echo "           }" >> /etc/nginx/roundcube.conf
		echo "           location ~* /README|INSTALL|LICENSE|SQL|bin|CHANGELOG\$ {" >> /etc/nginx/roundcube.conf
		echo "                   deny all;" >> /etc/nginx/roundcube.conf
		echo "           }" >> /etc/nginx/roundcube.conf
		echo "          }" >> /etc/nginx/roundcube.conf
		sed -i "s/server_name localhost;/server_name localhost; include \/etc\/nginx\/roundcube.conf;/" /etc/nginx/sites-enabled/default
	  fi
    cd /var/www/roundcube/config
    mv config.inc.php.sample config.inc.php

    sed -i "s|mysql://roundcube:pass@localhost/roundcubemail|mysqli://$roundcube_user:$roundcube_pass@localhost/$roundcube_db|"/var/www/roundcube/config/config.inc.php
    sed -i "s|^\(\$config\['default_host'\] =\).*$|\1 \'%s\';|"/var/www/roundcube/config/config.inc.php
    sed -i "s|^\(\$config\['smtp_user'\] =\).*$|\1 \'%u\';|"/var/www/roundcube/config/config.inc.php
    sed -i "s|^\(\$config\['smtp_pass'\] =\).*$|\1 \'%p\';|"/var/www/roundcube/config/config.inc.php

;;
	"squirrelmail")
	  echo "dictionaries-common dictionaries-common/default-wordlist select american (American English)" | debconf-set-selections
	  apt-get -y install squirrelmail wamerican > /dev/null 2>&1
	  ln -s /etc/squirrelmail/apache.conf /etc/apache2/conf-available/squirrelmail.conf
	  a2enconf squirrelmail
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
	  ;;
  esac
  if [ $CFG_WEBSERVER == "apache" ]; then
	  service apache2 restart > /dev/null 2>&1
  else
	  service nginx restart > /dev/null 2>&1
  fi
  echo -e "${green}done! ${NC}\n"
}
