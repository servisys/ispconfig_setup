InstallFix(){
  if [ "$CFG_DKIM" == "n" ]; then
	mkdir -p /var/db/dkim/
	amavisd-new genrsa /var/db/dkim/$CFG_HOSTNAME_FQDN.key.pem
	sed -i 's/$enable_dkim_verification = 0; #disabled to prevent warning/#$enable_dkim_verification = 0; #disabled to prevent warning/' /etc/amavis/conf.d/20-debian_defaults
	echo "\$enable_dkim_verification = 1;"  >> /etc/amavis/conf.d/20-debian_defaults
	echo "\$enable_dkim_signing = 1;"  >> /etc/amavis/conf.d/20-debian_defaults
	echo "dkim_key('$CFG_HOSTNAME_FQDN', 'dkim', '/var/db/dkim/$CFG_HOSTNAME_FQDN.key.pem');"  >> /etc/amavis/conf.d/20-debian_defaults
	echo "@dkim_signature_options_bysender_maps = ({ '.' => { ttl => 21*24*3600, c => 'relaxed/simple' } } );"  >> /etc/amavis/conf.d/20-debian_defaults
	MYNET=$(grep "mynetworks =" /etc/postfix/main.cf | sed 's/mynetworks = //')
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
