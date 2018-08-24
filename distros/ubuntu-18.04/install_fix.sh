InstallFix(){
	echo "@mynetworks = qw( $MYNET );" >> /etc/amavis/conf.d/20-debian_defaults
	if [ -f /etc/init.d/amavisd-new ]; then
		service amavisd-new restart > /dev/null 2>&1
	else
		service amavis restart > /dev/null 2>&1
	fi  
}
