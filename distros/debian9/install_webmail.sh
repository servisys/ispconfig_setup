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
	  apt-get -yqq install roundcube roundcube-core roundcube-mysql roundcube-plugins
	  sed -i "s/\$config\['default_host'\] = '';/\$config['default_host'] = 'localhost';/" /etc/roundcube/config.inc.php
	  if [ $CFG_WEBSERVER == "apache" ]; then
		echo "Alias /webmail /var/lib/roundcube" >> /etc/apache2/conf-enabled/roundcube.conf
		service apache2 reload
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
