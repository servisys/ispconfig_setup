#---------------------------------------------------------------------
# Function: InstallWebmail
#    Install the chosen webmail client. Squirrelmail or Roundcube
#---------------------------------------------------------------------
InstallWebmail() {
  echo -n "Installing Webmail client (SquirrelMail)... "
  echo "dictionaries-common dictionaries-common/default-wordlist select american (American English)" | debconf-set-selections
  apt_install squirrelmail wamerican
  ln -s /etc/squirrelmail/apache.conf /etc/apache2/conf-enabled/squirrelmail.conf
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

