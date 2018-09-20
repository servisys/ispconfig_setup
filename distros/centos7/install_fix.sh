InstallFix(){
  if [ "$CFG_WEBMAIL" == "roundcube" ]; then
  	echo "Installing Roundcube fix... "
	cd /tmp
	git clone https://github.com/w2c/ispconfig3_roundcube.git
	cd /tmp/ispconfig3_roundcube/
	mv ispconfig3_* /var/lib/roundcube/plugins
	cd /var/lib/roundcube/plugins
	mv ispconfig3_account/config/config.inc.php.dist ispconfig3_account/config/config.inc.php
	read -p "If you heaven't done yet add roundcube remtoe user in ISPConfig, with the following permission: Server functions - Client functions - Mail user functions - Mail alias functions - Mail spamfilter user functions - Mail spamfilter policy functions - Mail fetchmail functions - Mail spamfilter whitelist functions - Mail spamfilter blacklist functions - Mail user filter functions"
	sed -i "s/\$rcmail_config\['plugins'\] = array();/\$rcmail_config\['plugins'\] = array(\"jqueryui\", \"ispconfig3_account\", \"ispconfig3_autoreply\", \"ispconfig3_pass\", \"ispconfig3_spam\", \"ispconfig3_fetchmail\", \"ispconfig3_filter\");/" /etc/roundcube/main.inc.php
	sed -i "s/\$rcmail_config\['skin'\] = 'default';/\$rcmail_config\['skin'\] = 'classic';/" /etc/roundcube/main.inc.php
	#nano /var/lib/roundcube/plugins/ispconfig3_account/config/config.inc.php #  <---- This should not be a Part of Installer. Every Admi can add this after Installation
	echo -e "[${green}DONE${NC}]\n"
  fi
  if [ $CFG_DKIM == "n" ]; then
	mkdir -p /var/db/dkim/
	amavisd-new genrsa /var/db/dkim/$CFG_HOSTNAME_FQDN.key.pem
	sed -i 's/$enable_dkim_verification = 0; #disabled to prevent warning/#$enable_dkim_verification = 0; #disabled to prevent warning/' /etc/amavis/conf.d/20-debian_defaults
	echo "\$enable_dkim_verification = 1;"  >> /etc/amavis/conf.d/20-debian_defaults
	echo "\$enable_dkim_signing = 1;"  >> /etc/amavis/conf.d/20-debian_defaults
	echo "dkim_key('$CFG_HOSTNAME_FQDN', 'dkim', '/var/db/dkim/$CFG_HOSTNAME_FQDN.key.pem');"  >> /etc/amavis/conf.d/20-debian_defaults
	echo "@dkim_signature_options_bysender_maps = ({ '.' => { ttl => 21*24*3600, c => 'relaxed/simple' } } );"  >> /etc/amavis/conf.d/20-debian_defaults
	MYNET=$(grep "mynetworks =" cat /etc/postfix/main.cf | sed 's/mynetworks = //')
	echo "@mynetworks = qw( $MYNET );" >> /etc/amavis/conf.d/20-debian_defaults
	if [ -f /etc/init.d/amavisd-new ]; then
		echo -n "Restarting Amavisd-new... "
		service amavisd-new restart
	else
		echo -n "Restarting Amavisd... "
		service amavis restart
	fi
	echo -e "[${green}DONE${NC}]\n"
  fi  
}
