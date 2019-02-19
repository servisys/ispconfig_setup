#---------------------------------------------------------------------
# Function: InstallWebmail
#    Install the chosen webmail client. Squirrelmail or Roundcube
#---------------------------------------------------------------------
InstallWebmail() {
	echo -e "\n${red}Sorry but Webmail is not yet supported.${NC}" >&2
	echo -e "For more information, see this issue: https://github.com/servisys/ispconfig_setup/issues/179\n"
#  case $CFG_WEBMAIL in
#	"roundcube")
#	  echo -n "Installing Webmail client (Roundcube)... "
#	  CFG_ROUNDCUBE_PWD=$(< /dev/urandom tr -dc A-Z-a-z-0-9 | head -c12)
#	  echo "roundcube-core roundcube/dbconfig-install boolean true" | debconf-set-selections
#	  echo "roundcube-core roundcube/database-type select mysql" | debconf-set-selections
#	  echo "roundcube-core roundcube/mysql/admin-pass password $CFG_MYSQL_ROOT_PWD" | debconf-set-selections
#	  echo "roundcube-core roundcube/db/dbname string roundcube" | debconf-set-selections
#	  echo "roundcube-core roundcube/mysql/app-pass password $CFG_ROUNDCUBE_PWD" | debconf-set-selections
#	  echo "roundcube-core roundcube/app-password-confirm password $CFG_ROUNDCUBE_PWD" | debconf-set-selections
#	  echo "roundcube-core roundcube/hosts string localhost" | debconf-set-selections
#	  apt_install roundcube roundcube-core roundcube-mysql roundcube-plugins roundcube-plugins-extra javascript-common libjs-jquery-mousewheel php-net-sieve tinymce
# 
#
#  echo -n "Installing Webmail client (SquirrelMail)... "
#  echo "dictionaries-common dictionaries-common/default-wordlist select american (American English)" | debconf-set-selections
#  apt_install squirrelmail wamerican
#  ln -s /etc/squirrelmail/apache.conf /etc/apache2/conf-enabled/squirrelmail.conf
#  sed -i 1d /etc/squirrelmail/apache.conf
#  sed -i '1iAlias /webmail /usr/share/squirrelmail' /etc/squirrelmail/apache.conf
#
#	case $CFG_MTA in
#		"courier")
#		  sed -i 's/$imap_server_type       = "other";/$imap_server_type       = "courier";/' /etc/squirrelmail/config.php
#		  sed -i 's/$optional_delimiter     = "detect";/$optional_delimiter     = ".";/' /etc/squirrelmail/config.php
#		  sed -i 's/$default_folder_prefix          = "";/$default_folder_prefix          = "INBOX.";/' /etc/squirrelmail/config.php
#		  sed -i 's/$trash_folder                   = "INBOX.Trash";/$trash_folder                   = "Trash";/' /etc/squirrelmail/config.php
#		  sed -i 's/$sent_folder                    = "INBOX.Sent";/$sent_folder                    = "Sent";/' /etc/squirrelmail/config.php
#		  sed -i 's/$draft_folder                   = "INBOX.Drafts";/$draft_folder                   = "Drafts";/' /etc/squirrelmail/config.php
#		  sed -i 's/$default_sub_of_inbox           = true;/$default_sub_of_inbox           = false;/' /etc/squirrelmail/config.php
#		  sed -i 's/$delete_folder                  = false;/$delete_folder                  = true;/' /etc/squirrelmail/config.php
#		  ;;
#		"dovecot")
#		  sed -i 's/$imap_server_type       = "other";/$imap_server_type       = "dovecot";/' /etc/squirrelmail/config.php
#		  sed -i 's/$trash_folder                   = "INBOX.Trash";/$trash_folder                   = "Trash";/' /etc/squirrelmail/config.php
#		  sed -i 's/$sent_folder                    = "INBOX.Sent";/$sent_folder                    = "Sent";/' /etc/squirrelmail/config.php
#		  sed -i 's/$draft_folder                   = "INBOX.Drafts";/$draft_folder                   = "Drafts";/' /etc/squirrelmail/config.php
#		  sed -i 's/$default_sub_of_inbox           = true;/$default_sub_of_inbox           = false;/' /etc/squirrelmail/config.php
#		  sed -i 's/$delete_folder                  = false;/$delete_folder                  = true;/' /etc/squirrelmail/config.php
#		  ;;
#	  esac
# mkdir /var/lib/squirrelmail/tmp
#  chown www-data /var/lib/squirrelmail/tmp
# echo -e "[${green}DONE${NC}]\n"
# if [ "$CFG_WEBSERVER" == "apache" ]; then
#	  echo -n "Restarting Apache... "
#	  service apache2 restart
#  elif [ "$CFG_WEBSERVER" == "nginx" ]; then
#	  echo -n "Restarting nginx... "
#	  service nginx restart
#  fi
#  echo -e "[${green}DONE${NC}]\n"
}

