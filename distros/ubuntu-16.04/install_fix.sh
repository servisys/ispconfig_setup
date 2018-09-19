InstallFix(){
	echo "@mynetworks = qw( $MYNET );" >> /etc/amavis/conf.d/20-debian_defaults
	if [ -f /etc/init.d/amavisd-new ]; then
		echo -n "Restarting Amavisd-new... "
		service amavisd-new restart
	else
		echo -n "Restarting Amavisd... "
		service amavis restart
	fi  
	echo -e "[${green}DONE${NC}]\n"
}
