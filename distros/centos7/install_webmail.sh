#---------------------------------------------------------------------
# Function: InstallWebmail
#    Install the chosen webmail client. Squirrelmail or Roundcube
#---------------------------------------------------------------------
InstallWebmail() {
  case $CFG_WEBMAIL in
	"roundcube")
	  echo -n "Installing Webmail client (Roundcube)... "
	  yum_install roundcubemail
	  mysql -u root -p$CFG_MYSQL_ROOT_PWD -e 'CREATE DATABASE '$ROUNDCUBE_DB';'
	  mysql -u root -p$CFG_MYSQL_ROOT_PWD -e "CREATE USER '$ROUNDCUBE_USER'@localhost IDENTIFIED BY '$ROUNDCUBE_PWD'"
	  mysql -u root -p$CFG_MYSQL_ROOT_PWD -e 'GRANT ALL PRIVILEGES on '$ROUNDCUBE_DB'.* to '$ROUNDCUBE_USER'@localhost'
	  mysql -u root -p$CFG_MYSQL_ROOT_PWD -e 'FLUSH PRIVILEGES;'
	  grep -v db_dsnw /etc/roundcubemail/config.inc.php.sample > /etc/roundcubemail/config.inc.php
	  sed -i "/$config = array();/ a \$config[\\'db_dsnw\\'] = \\'mysql:\/\/$ROUNDCUBE_USER:$ROUNDCUBE_PWD@localhost\/$ROUNDCUBE_DB\\';" /etc/roundcubemail/config.inc.php
	  mysql -u $ROUNDCUBE_USER -p$ROUNDCUBE_PWD $ROUNDCUBE_DB < /usr/share/roundcubemail/SQL/mysql.initial.sql
	  if [ "$CFG_WEBSERVER" == "apache" ]; then
		echo "Alias /roundcubemail /usr/share/roundcubemail" > /etc/httpd/conf.d/roundcubemail.conf
		echo "Alias /webmail /usr/share/roundcubemail" >> /etc/httpd/conf.d/roundcubemail.conf
		echo "<Directory /usr/share/roundcubemail/>" >> /etc/httpd/conf.d/roundcubemail.conf
		echo "        Options none" >> /etc/httpd/conf.d/roundcubemail.conf
		echo "        AllowOverride Limit" >> /etc/httpd/conf.d/roundcubemail.conf
		echo "        Require all granted" >> /etc/httpd/conf.d/roundcubemail.conf
		echo "</Directory>" >> /etc/httpd/conf.d/roundcubemail.conf
		echo "<Directory /usr/share/roundcubemail/installer>" >> /etc/httpd/conf.d/roundcubemail.conf
		echo "        Options none" >> /etc/httpd/conf.d/roundcubemail.conf
		echo "        AllowOverride Limit" >> /etc/httpd/conf.d/roundcubemail.conf
		echo "        Require all granted" >> /etc/httpd/conf.d/roundcubemail.conf
		echo "</Directory>" >> /etc/httpd/conf.d/roundcubemail.conf
		echo "<Directory /usr/share/roundcubemail/bin/>" >> /etc/httpd/conf.d/roundcubemail.conf
		echo "    Order Allow,Deny" >> /etc/httpd/conf.d/roundcubemail.conf
		echo "    Deny from all" >> /etc/httpd/conf.d/roundcubemail.conf
		echo "</Directory>" >> /etc/httpd/conf.d/roundcubemail.conf
		echo "<Directory /usr/share/roundcubemail/plugins/enigma/home/>" >> /etc/httpd/conf.d/roundcubemail.conf
		echo "    Order Allow,Deny" >> /etc/httpd/conf.d/roundcubemail.conf
		echo "    Deny from all" >> /etc/httpd/conf.d/roundcubemail.conf
		echo "</Directory>" >> /etc/httpd/conf.d/roundcubemail.conf
	  elif [ "$CFG_WEBSERVER" == "nginx" ]; then
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
	;;
	"squirrelmail")
	  echo -n "Installing Webmail client (SquirrelMail)... "
	  echo -e "\n${red}Sorry but SquirrelMail is not yet supported.${NC}" >&2
	  echo -e "For more information, see this issue: https://github.com/servisys/ispconfig_setup/issues/68\n"
	  # echo "dictionaries-common dictionaries-common/default-wordlist select american (American English)" | debconf-set-selections
	  # apt-get -y install squirrelmail wamerican
	  # ln -s /etc/squirrelmail/apache.conf /etc/apache2/conf.d/squirrelmail
	  # sed -i 1d /etc/squirrelmail/apache.conf
	  # sed -i '1iAlias /webmail /usr/share/squirrelmail' /etc/squirrelmail/apache.conf

	  # case $CFG_MTA in
		# "courier")
		  # sed -i 's/$imap_server_type       = "other";/$imap_server_type       = "courier";/' /etc/squirrelmail/config.php
		  # sed -i 's/$optional_delimiter     = "detect";/$optional_delimiter     = ".";/' /etc/squirrelmail/config.php
		  # sed -i 's/$default_folder_prefix          = "";/$default_folder_prefix          = "INBOX.";/' /etc/squirrelmail/config.php
		  # sed -i 's/$trash_folder                   = "INBOX.Trash";/$trash_folder                   = "Trash";/' /etc/squirrelmail/config.php
		  # sed -i 's/$sent_folder                    = "INBOX.Sent";/$sent_folder                    = "Sent";/' /etc/squirrelmail/config.php
		  # sed -i 's/$draft_folder                   = "INBOX.Drafts";/$draft_folder                   = "Drafts";/' /etc/squirrelmail/config.php
		  # sed -i 's/$default_sub_of_inbox           = true;/$default_sub_of_inbox           = false;/' /etc/squirrelmail/config.php
		  # sed -i 's/$delete_folder                  = false;/$delete_folder                  = true;/' /etc/squirrelmail/config.php
		  # ;;
		# "dovecot")
		  # sed -i 's/$imap_server_type       = "other";/$imap_server_type       = "dovecot";/' /etc/squirrelmail/config.php
		  # sed -i 's/$trash_folder                   = "INBOX.Trash";/$trash_folder                   = "Trash";/' /etc/squirrelmail/config.php
		  # sed -i 's/$sent_folder                    = "INBOX.Sent";/$sent_folder                    = "Sent";/' /etc/squirrelmail/config.php
		  # sed -i 's/$draft_folder                   = "INBOX.Drafts";/$draft_folder                   = "Drafts";/' /etc/squirrelmail/config.php
		  # sed -i 's/$default_sub_of_inbox           = true;/$default_sub_of_inbox           = false;/' /etc/squirrelmail/config.php
		  # sed -i 's/$delete_folder                  = false;/$delete_folder                  = true;/' /etc/squirrelmail/config.php
		  # ;;
	  # esac
	  ;;
  esac
  echo -e "[${green}DONE${NC}]\n"
  if [ "$CFG_WEBSERVER" == "apache" ]; then
	  echo -n "Restarting Apache... "
	  systemctl restart httpd.service
  elif [ "$CFG_WEBSERVER" == "nginx" ]; then
	  echo -n "Restarting nginx... "
	  service nginx restart
  fi
  echo -e "[${green}DONE${NC}]\n"
}

