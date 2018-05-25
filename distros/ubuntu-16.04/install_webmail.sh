#---------------------------------------------------------------------
# Function: InstallWebmail
#    Install the chosen webmail client. Squirrelmail or Roundcube
#---------------------------------------------------------------------
InstallWebmail() {
  echo -n "Installing webmail client ($CFG_WEBMAIL)... "
  if [ "$CFG_WEBMAIL" == "roundcube" ]; then
	echo "==========================================================================================="
	echo "Attention: When asked 'Configure database for roundcube with dbconfig-common?' select 'Yes'"
	echo "Attention: When asked 'MySQL application password for roundcube:' donot set password!"
	echo "Just press <enter> here"
	echo "Due to a bug in dbconfig-common, this can't be automated."
	echo "==========================================================================================="
	echo "Press ENTER to continue... "
	read DUMMY
	apt-get -y install roundcube roundcube-core roundcube-mysql roundcube-plugins roundcube-plugins-extra javascript-common libjs-jquery-mousewheel php-net-sieve tinymce
	sed -i "s|^\(\$config\['default_host'\] =\).*$|\1 \'localhost\';|" /etc/roundcube/config.inc.php
	ln -s /usr/share/roundcube /usr/share/squirrelmail

  fi
}

