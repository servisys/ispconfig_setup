InstallTheme() {
	echo "Installing Theme... "

	cd /tmp
	wget https://github.com/dclardy64/ISPConfig_Clean-3.0.5/archive/master.zip
	unzip master.zip
	cd ISPConfig_Clean-3.0.5-master
	cp -R interface/* /usr/local/ispconfig/interface/

	sed -i "s|\$conf\['theme'\] = 'default'|\$conf\['theme'\] = 'ispc-clean'|" /usr/local/ispconfig/interface/lib/config.inc.php
	sed -i "s|\$conf\['logo'\] = 'themes/default|\$conf\['logo'\] = 'themes/ispc-clean|" /usr/local/ispconfig/interface/lib/config.inc.php


	mysql -u root -p$CFG_MYSQL_ROOT_PWD < sql/ispc-clean.sql

	echo -e "[${green}DONE${NC}]\n"
}
