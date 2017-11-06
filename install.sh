#!/usr/bin/env bash
#---------------------------------------------------------------------
# install.sh
#
# ISPConfig 3 system installer
#
# Script: install.sh
# Version: 3.0.2
# Author: Matteo Temporini <temporini.matteo@gmail.com>
# Description: This script will install all the packages needed to install
# ISPConfig 3 on your server.
#
#
#---------------------------------------------------------------------

#Those lines are for logging porpuses
exec > >(tee -i /var/log/ispconfig_setup.log)
exec 2>&1

#---------------------------------------------------------------------
# Global variables
#---------------------------------------------------------------------
CFG_HOSTNAME_FQDN=`hostname -f`;
WT_BACKTITLE="ISPConfig 3 System Installer from Temporini Matteo"

# Bash Colour
red='\033[0;31m'
green='\033[0;32m'
NC='\033[0m' # No Color


#Saving current directory
PWD=$(pwd);

#---------------------------------------------------------------------
# Load needed functions
#---------------------------------------------------------------------

source $PWD/functions/check_linux.sh
echo "Checking your system, please wait..."
CheckLinux

#---------------------------------------------------------------------
# Load needed Modules
#---------------------------------------------------------------------

source $PWD/distros/$DISTRO/preinstallcheck.sh
source $PWD/distros/$DISTRO/askquestions.sh

source $PWD/distros/$DISTRO/install_basics.sh
source $PWD/distros/$DISTRO/install_postfix.sh
source $PWD/distros/$DISTRO/install_mysql.sh
source $PWD/distros/$DISTRO/install_mta.sh
source $PWD/distros/$DISTRO/install_antivirus.sh
source $PWD/distros/$DISTRO/install_webserver.sh
source $PWD/distros/$DISTRO/install_hhvm.sh
source $PWD/distros/$DISTRO/install_ftp.sh
source $PWD/distros/$DISTRO/install_quota.sh
source $PWD/distros/$DISTRO/install_bind.sh
source $PWD/distros/$DISTRO/install_webstats.sh
source $PWD/distros/$DISTRO/install_jailkit.sh
source $PWD/distros/$DISTRO/install_fail2ban.sh
source $PWD/distros/$DISTRO/install_webmail.sh
source $PWD/distros/$DISTRO/install_metronom.sh
source $PWD/distros/$DISTRO/install_ispconfig.sh
source $PWD/distros/$DISTRO/install_fix.sh

source $PWD/distros/$DISTRO/install_basephp.sh #to remove in feature release
#---------------------------------------------------------------------
# Main program [ main() ]
#    Run the installer
#---------------------------------------------------------------------
clear

echo "Welcome to ISPConfig Setup Script v.3.0.2"
echo "This software is developed by Temporini Matteo"
echo "with the support of the community."
echo "You can visit my website at the followings URLs"
echo "http://www.servisys.it http://www.temporini.net"
echo "and contact me with the following information"
echo "contact email/hangout: temporini.matteo@gmail.com"
echo "skype: matteo.temporini"
echo "========================================="
echo "ISPConfig 3 System installer"
echo "========================================="
echo
echo "This script will do a nearly unattended installation of"
echo "all software needed to run ISPConfig 3."
echo "When this script starts running, it'll keep going all the way"
echo "So before you continue, please make sure the following checklist is ok:"
echo
echo "- This is a clean standard clean installation for supported systems";
echo "- Internet connection is working properly";
echo
echo
if [ -n "$PRETTY_NAME" ]; then
	echo -e "The detected Linux Distribution is: " $PRETTY_NAME
else
	echo -e "The detected Linux Distribution is: " $ID-$VERSION_ID
fi
echo
if [ -n "$DISTRO" ]; then
	read -p "Is this correct? (y/n)" -n 1 -r
	echo    # (optional) move to a new line
	if [[ ! $REPLY =~ ^[Yy]$ ]]
		then
		exit 1
	fi
else
	echo -e "Sorry but your System is not supported by this script, if you want your system supported "
	echo -e "open an issue on GitHub: https://github.com/servisys/ispconfig_setup"
	exit 1
fi

if [ "$DISTRO" == "debian8" ]; then
	     while [ "x$CFG_ISPCVERSION" == "x" ]
          do
                CFG_ISPCVERSION=$(whiptail --title "ISPConfig Version" --backtitle "$WT_BACKTITLE" --nocancel --radiolist "Select ISPConfig Version you want to install" 10 50 2 "Stable" "(default)" ON "Beta" "" OFF 3>&1 1>&2 2>&3)
          done
         while [ "x$CFG_MULTISERVER" == "x" ]
          do
                CFG_MULTISERVER=$(whiptail --title "MULTISERVER SETUP" --backtitle "$WT_BACKTITLE" --nocancel --radiolist "Would you like to install ISPConfig in a MultiServer Setup?" 10 50 2 "no" "(default)" ON "yes" "" OFF 3>&1 1>&2 2>&3)
          done
else
	CFG_MULTISERVER=no
fi

if [ -f /etc/debian_version ]; then
  PreInstallCheck
  if [ "$CFG_MULTISERVER" == "no" ]; then
	AskQuestions
  else
    source $PWD/distros/$DISTRO/askquestions_multiserver.sh
	AskQuestionsMultiserver
  fi
  InstallBasics 
  InstallSQLServer 
  if [ "$CFG_SETUP_WEB" == "yes" ] || [ "$CFG_MULTISERVER" == "no" ]; then
    InstallWebServer
    InstallFTP 
    if [ "$CFG_QUOTA" == "yes" ]; then
    	InstallQuota 
    fi
    if [ "$CFG_JKIT" == "yes" ]; then
    	InstallJailkit 
    fi
    if [ "$CFG_HHVM" == "yes" ]; then
    	InstallHHVM
    fi
    if [ "$CFG_METRONOM" == "yes" ]; then
    	InstallMetronom 
    fi
    InstallWebmail 
  else
    InstallBasePhp    #to remove in feature release
  fi  
  if [ "$CFG_SETUP_MAIL" == "yes" ] || [ "$CFG_MULTISERVER" == "no" ]; then
    InstallPostfix 
    InstallMTA 
    InstallAntiVirus 
  fi  
  if [ "$CFG_SETUP_NS" == "yes" ] || [ "$CFG_MULTISERVER" == "no" ]; then
    InstallBind 
  fi
  InstallWebStats
  InstallFail2ban
  if [ "$CFG_ISPCVERSION" == "Beta" ]; then
		source $PWD/distros/$DISTRO/install_ispconfigbeta.sh
		InstallISPConfigBeta
  fi
  InstallISPConfig
  InstallFix
  echo -e "${green}Well done ISPConfig installed and configured correctly :D ${NC}"
  echo "Now you can connect to your ISPConfig installation at https://$CFG_HOSTNAME_FQDN:8080 or https://IP_ADDRESS:8080"
  echo "You can visit my GitHub profile at https://github.com/servisys/ispconfig_setup/"
  if [ "$CFG_WEBMAIL" == "roundcube" ]; then
    if [ "$DISTRO" != "debian8" ]; then
		echo -e "${red}You had to edit user/pass /var/lib/roundcube/plugins/ispconfig3_account/config/config.inc.php of roudcube user, as the one you inserted in ISPconfig ${NC}"
	fi
  fi
  if [ "$CFG_WEBSERVER" == "nginx" ]; then
  	if [ "$CFG_PHPMYADMIN" == "yes" ]; then
  		echo "Phpmyadmin is accessibile at  http://$CFG_HOSTNAME_FQDN:8081/phpmyadmin or http://IP_ADDRESS:8081/phpmyadmin";
	fi
	if [ "$DISTRO" == "debian8" ] && [ "$CFG_WEBMAIL" == "roundcube" ]; then
		echo "Webmail is accessibile at  https://$CFG_HOSTNAME_FQDN/webmail or https://IP_ADDRESS/webmail";
	else
		echo "Webmail is accessibile at  http://$CFG_HOSTNAME_FQDN:8081/webmail or http://IP_ADDRESS:8081/webmail";
	fi
  fi
else 
	if [ -f /etc/centos-release ]; then
		echo "Attention please, this is the very first version of the script for CentOS 7"
		echo "Please use only for test purpose for now."
		echo -e "${red}Not yet implemented: courier, nginx support${NC}"
		echo -e "${green}Implemented: apache, mysql, bind, postfix, dovecot, roundcube webmail support${NC}"
		echo "Help us to test and implement, press ENTER if you understand what I'm talking about..."
		read DUMMY
		source $PWD/distros/$DISTRO/install_mailman.sh
		PreInstallCheck
		AskQuestions 
		InstallBasics 
		InstallPostfix 
		InstallSQLServer 
		InstallMTA 
		InstallAntiVirus 
		InstallWebServer
		InstallFTP 
		#if [ $CFG_QUOTA == "yes" ]; then
		#		InstallQuota 
		#fi
		InstallBind 
        InstallWebStats 
	    if [ "$CFG_JKIT" == "yes" ]; then
			InstallJailkit 
	    fi
		InstallFail2ban 
		if [ "$CFG_METRONOM" == "yes" ]; then
			InstallMetronom 
		fi
		InstallWebmail 
		InstallISPConfig
		#InstallFix
		echo -e "${green}Well done! ISPConfig installed and configured correctly :D ${NC}"
		echo "Now you can connect to your ISPConfig installation at https://$CFG_HOSTNAME_FQDN:8080 or https://IP_ADDRESS:8080"
		echo "You can visit my GitHub profile at https://github.com/servisys/ispconfig_setup/"
		echo -e "${red}If you setup Roundcube webmail go to http://$CFG_HOSTNAME_FQDN/roundcubemail/installer and configure db connection${NC}"
		echo -e "${red}After that disable access to installer in /etc/httpd/conf.d/roundcubemail.conf${NC}"
	else
		echo "${red}Unsupported linux distribution.${NC}"
	fi
fi

exit 0

