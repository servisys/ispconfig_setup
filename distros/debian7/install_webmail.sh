#---------------------------------------------------------------------
# Function: InstallWebmail
#    Install the chosen webmail client. Squirrelmail or Roundcube
#---------------------------------------------------------------------
InstallWebmail() {
  case $CFG_WEBMAIL in
	"roundcube")
	  echo -n "Installing Webmail client (Roundcube)... "
	  RANDPWD=$(date +%N%s | md5sum)
	  echo "roundcube-core roundcube/dbconfig-install boolean true" | debconf-set-selections
	  echo "roundcube-core roundcube/database-type select mysql" | debconf-set-selections
	  echo "roundcube-core roundcube/mysql/admin-pass password $CFG_MYSQL_ROOT_PWD" | debconf-set-selections
	  echo "roundcube-core roundcube/db/dbname string roundcube" | debconf-set-selections
	  echo "roundcube-core roundcube/mysql/app-pass password $RANDOMPWD" | debconf-set-selections
	  echo "roundcube-core roundcube/app-password-confirm password $RANDPWD" | debconf-set-selections
	  apt_install roundcube roundcube-mysql git
	  echo -n "Installing Webmail client Plugins (Roundcube)... "
	  cd /tmp
	  wget -q -O ispconfig3_roundcube.tgz https://github.com/w2c/ispconfig3_roundcube/tarball/master
	  tar xzf ispconfig3_roundcube.tgz
	  cp -r /tmp/*ispconfig3_roundcube*/ispconfig3_* /usr/share/roundcube/plugins/
	  ln -s /usr/share/roundcube/plugins/ispconfig3_account /var/lib/roundcube/plugins/ispconfig3_account
	  ln -s /usr/share/roundcube/plugins/ispconfig3_autoreply /var/lib/roundcube/plugins/ispconfig3_autoreply
	  ln -s /usr/share/roundcube/plugins/ispconfig3_autoselect /var/lib/roundcube/plugins/ispconfig3_autoselect
	  ln -s /usr/share/roundcube/plugins/ispconfig3_fetchmail /var/lib/roundcube/plugins/ispconfig3_fetchmail
	  ln -s /usr/share/roundcube/plugins/ispconfig3_filter /var/lib/roundcube/plugins/ispconfig3_filter
	  ln -s /usr/share/roundcube/plugins/ispconfig3_forward /var/lib/roundcube/plugins/ispconfig3_forward
	  ln -s /usr/share/roundcube/plugins/ispconfig3_pass /var/lib/roundcube/plugins/ispconfig3_pass
	  ln -s /usr/share/roundcube/plugins/ispconfig3_spam /var/lib/roundcube/plugins/ispconfig3_spam
	  ln -s /usr/share/roundcube/plugins/ispconfig3_wblist /var/lib/roundcube/plugins/ispconfig3_wblist
	  sed -i "/'zipdownload',/a 'jqueryui',\n'ispconfig3_account',\n'ispconfig3_autoreply',\n'ispconfig3_pass',\n'ispconfig3_spam',\n'ispconfig3_fetchmail',\n'ispconfig3_filter',\n'ispconfig3_forward'," /etc/roundcube/config.inc.php
	  mv /usr/share/roundcube/plugins/ispconfig3_account/config/config.inc.php.dist /usr/share/roundcube/plugins/ispconfig3_account/config/config.inc.php
	  sed -i "s/\$rcmail_config\['remote_soap_pass'\] = '.*';/\$rcmail_config\['remote_soap_pass'\] = '$CFG_ROUNDCUBE_PWD';/" /usr/share/roundcube/plugins/ispconfig3_account/config/config.inc.php
	  sed -i "s/\$rcmail_config\['soap_url'\] = '.*';/\$rcmail_config['soap_url'] = 'https\:\/\/$CFG_HOSTNAME_FQDN\:8080\/remote\/';/" /usr/share/roundcube/plugins/ispconfig3_account/config/config.inc.php
	  mv /usr/share/roundcube/plugins/ispconfig3_pass/config/config.inc.php.dist /usr/share/roundcube/plugins/ispconfig3_pass/config/config.inc.php
	  sed -i "s/\$rcmail_config\['password_min_length'\] = 6;/\$rcmail_config\['password_min_length'\] = 8;/" /usr/share/roundcube/plugins/ispconfig3_pass/config/config.inc.php
	  sed -i "s/\$rcmail_config\['password_check_symbol'\] = TRUE;/\$rcmail_config\['password_check_symbol'\] = FALSE;/" /usr/share/roundcube/plugins/ispconfig3_pass/config/config.inc.php
	  if [ "$CFG_WEBSERVER" == "apache" ]; then
	  	sed -i '1iAlias /webmail /var/lib/roundcube' /etc/roundcube/apache.conf
	  	sed -i "/Options +FollowSymLinks/a\\$(echo -e '\n\r')  DirectoryIndex index.php\\$(echo -e '\n\r')\\$(echo -e '\n\r')  <IfModule mod_php5.c>\\$(echo -e '\n\r')        AddType application/x-httpd-php .php\\$(echo -e '\n\r')\\$(echo -e '\n\r')        php_flag magic_quotes_gpc Off\\$(echo -e '\n\r')        php_flag track_vars On\\$(echo -e '\n\r')        php_flag register_globals Off\\$(echo -e '\n\r')        php_value include_path .:/usr/share/php\\$(echo -e '\n\r')  </IfModule>" /etc/roundcube/apache.conf
	  	sed -i "s/\$rcmail_config\['default_host'\] = '';/\$rcmail_config\['default_host'\] = 'localhost';/" /etc/roundcube/main.inc.php
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
	 echo "dictionaries-common dictionaries-common/default-wordlist select american (American English)" | debconf-set-selections
	  apt_install squirrelmail wamerican
	  ln -s /etc/squirrelmail/apache.conf /etc/apache2/conf.d/squirrelmail
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

