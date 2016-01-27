#!/bin/bash

###############################################################################################
# Complete ISPConfig setup script for Debian/Ubuntu Systems         						  #
# Drew Clardy												                                  # 
# http://drewclardy.com				                                                          #
# http://github.com/dclardy64/ISPConfig-3-Debian-Install                                      #
###############################################################################################

back_title="ISPConfig 3 Theme Installer"

theme_questions (){
	while [ "x$theme" == "x" ]
	do
		theme=$(whiptail --title "Theme" --backtitle "$back_title" --nocancel --radiolist "Select Theme" 10 50 2 "ISPC-Clean" "(default)" ON "Other" "" OFF 3>&1 1>&2 2>&3)
	done
	while [ "x$mysql_pass" == "x" ]
	do
		mysql_pass=$(whiptail --title "MySQL Root Password" --backtitle "$back_title" --inputbox "Please insert the MySQL Root Password" --nocancel 10 50 3>&1 1>&2 2>&3)
	done
}


function_install_ISPC_Clean() {

	# Get Theme
	cd /tmp
	wget https://github.com/dclardy64/ISPConfig_Clean-3.0.5/archive/master.zip
	unzip master.zip
	cd ISPConfig_Clean-3.0.5-master
	cp -R interface/* /usr/local/ispconfig/interface/

	sed -i "s|\$conf\['theme'\] = 'default'|\$conf\['theme'\] = 'ispc-clean'|" /usr/local/ispconfig/interface/lib/config.inc.php
	sed -i "s|\$conf\['logo'\] = 'themes/default|\$conf\['logo'\] = 'themes/ispc-clean|" /usr/local/ispconfig/interface/lib/config.inc.php

	mysql -u root -p$mysql_pass < sql/ispc-clean.sql

}