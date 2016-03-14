#---------------------------------------------------------------------
# Function: InstallWebmail
#    Install the chosen webmail client. Squirrelmail or Roundcube
#---------------------------------------------------------------------
InstallWebmail() {
  echo -n "Installing Webmail client ($CFG_WEBMAIL)... "
  case $CFG_WEBMAIL in
	"roundcube")
	  CFG_ROUNDCUBE_PWD=$(< /dev/urandom tr -dc A-Z-a-z-0-9 | head -c12)
	  echo "roundcube-core roundcube/dbconfig-install boolean true" | debconf-set-selections
	  echo "roundcube-core roundcube/database-type select mysql" | debconf-set-selections
	  echo "roundcube-core roundcube/mysql/admin-pass password $CFG_MYSQL_ROOT_PWD" | debconf-set-selections
	  echo "roundcube-core roundcube/db/dbname string roundcube" | debconf-set-selections
	  echo "roundcube-core roundcube/mysql/app-pass password $CFG_ROUNDCUBE_PWD" | debconf-set-selections
	  echo "roundcube-core roundcube/app-password-confirm password $CFG_ROUNDCUBE_PWD" | debconf-set-selections
	  echo "roundcube-core roundcube/hosts string localhost" | debconf-set-selections
	  backports=$(cat /etc/apt/sources.list | grep jessie-backports | grep -v "#")
	  if [ -z "$backports" ]; then
	    echo -e "\n# jessie-backports, previously on backports.debian.org" >> /etc/apt/sources.list
	    echo "deb http://http.debian.net/debian/ jessie-backports main contrib non-free" >> /etc/apt/sources.list
	    echo "deb-src http://http.debian.net/debian/ jessie-backports main contrib non-free" >> /etc/apt/sources.list
	  fi
	  apt-get -qq update
	  apt-get -yqq -t jessie-backports install roundcube roundcube-mysql roundcube-plugins > /dev/null 2>&1
	  if [ $CFG_WEBSERVER == "apache" ]; then
		mv /etc/roundcube/apache.conf /etc/roundcube/apache.conf.default
		cat << "EOF" > /etc/roundcube/apache.conf
<VirtualHost *:80>
	# Those aliases do not work properly with several hosts on your apache server
	# Uncomment them to use it or adapt them to your configuration
	#    Alias /roundcube /var/lib/roundcube
	Alias /webmail /var/lib/roundcube

	<Directory /var/lib/roundcube/>
	  Options +FollowSymLinks
	  # This is needed to parse /var/lib/roundcube/.htaccess. See its
	  # content before setting AllowOverride to None.
	  AllowOverride All
	  <IfVersion >= 2.3>
		Require all granted
	  </IfVersion>
	  <IfVersion < 2.3>
		Order allow,deny
		Allow from all
	  </IfVersion>
	</Directory>

	# Protecting basic directories:
	<Directory /var/lib/roundcube/config>
			Options -FollowSymLinks
			AllowOverride None
	</Directory>

	<Directory /var/lib/roundcube/temp>
			Options -FollowSymLinks
			AllowOverride None
			<IfVersion >= 2.3>
			  Require all denied
			</IfVersion>
			<IfVersion < 2.3>
			  Order allow,deny
			  Deny from all
			</IfVersion>
	</Directory>

	<Directory /var/lib/roundcube/logs>
			Options -FollowSymLinks
			AllowOverride None
			<IfVersion >= 2.3>
			  Require all denied
			</IfVersion>
			<IfVersion < 2.3>
			  Order allow,deny
			  Deny from all
			</IfVersion>
	</Directory>
</VirtualHost>

<IfModule mod_ssl.c>
<VirtualHost *:443>
	# Those aliases do not work properly with several hosts on your apache server
	# Uncomment them to use it or adapt them to your configuration
	#    Alias /roundcube /var/lib/roundcube
	Alias /webmail /var/lib/roundcube

	<Directory /var/lib/roundcube/>
	  Options +FollowSymLinks
	  # This is needed to parse /var/lib/roundcube/.htaccess. See its
	  # content before setting AllowOverride to None.
	  AllowOverride All
	  <IfVersion >= 2.3>
		Require all granted
	  </IfVersion>
	  <IfVersion < 2.3>
		Order allow,deny
		Allow from all
	  </IfVersion>
	</Directory>

	# Protecting basic directories:
	<Directory /var/lib/roundcube/config>
			Options -FollowSymLinks
			AllowOverride None
	</Directory>

	<Directory /var/lib/roundcube/temp>
			Options -FollowSymLinks
			AllowOverride None
			<IfVersion >= 2.3>
			  Require all denied
			</IfVersion>
			<IfVersion < 2.3>
			  Order allow,deny
			  Deny from all
			</IfVersion>
	</Directory>

	<Directory /var/lib/roundcube/logs>
			Options -FollowSymLinks
			AllowOverride None
			<IfVersion >= 2.3>
			  Require all denied
			</IfVersion>
			<IfVersion < 2.3>
			  Order allow,deny
			  Deny from all
			</IfVersion>
	</Directory>

	# SSL Configuration
	SSLEngine On
	SSLProtocol All -SSLv2 -SSLv3
	SSLCertificateFile /usr/local/ispconfig/interface/ssl/ispserver.crt
	SSLCertificateKeyFile /usr/local/ispconfig/interface/ssl/ispserver.key
	#SSLCACertificateFile /usr/local/ispconfig/interface/ssl/ispserver.bundle
</VirtualHost>
</IfModule>
EOF
	  else
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
        fastcgi_pass unix:/var/run/php5-fpm.sock;
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
	  # ISPConfig integration
	  cd /tmp
	  wget -q --no-check-certificate -O ispconfig3_roundcube.tgz https://github.com/w2c/ispconfig3_roundcube/tarball/master
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
    ;;
	"squirrelmail")
	  if [ $CFG_WEBSERVER == "apache" ]; then
	    echo "dictionaries-common dictionaries-common/default-wordlist select american (American English)" | debconf-set-selections
	    apt-get -yqq install squirrelmail wamerican > /dev/null 2>&1
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
	  fi	
	;;
  esac
  if [ $CFG_WEBSERVER == "apache" ]; then
	  service apache2 restart > /dev/null 2>&1
  else
	  service nginx restart > /dev/null 2>&1
  fi
  echo -e "[${green}DONE${NC}]\n"
}
