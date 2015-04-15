#!/bin/bash
#---------------------------------------------------------------------
# ispc3sysinstall.sh
#
# ISPConfig 3 system installer
#
# Script: ispc3sysinstall.sh
# Version: 1.0.5
# Author: Mark Stunnenberg <mark@e-rave.nl>
# Description: This script will install all the packages needed to install
# ISPConfig 3 on your server.
#
#
#---------------------------------------------------------------------



#---------------------------------------------------------------------
# Global variables
#---------------------------------------------------------------------
CFG_HOSTNAME_FQDN=`hostname -f`;
WT_BACKTITLE="ISPConfig 3 System Installer from Temporini Matteo"

# Bash Colour
red='\033[0;31m'
green='\033[0;32m'
NC='\033[0m' # No Color

#Program Versions
JKV="2.17"  #Jailkit Version -> Maybe this can be automated

#Saving current directory
PWD=$(pwd);

clear

# Check if user is root
if [ $(id -u) != "0" ]; then
    echo "${red}Error:${red} You must be root to run this script. Please switch to root user to install ispconfig3 and needed software."
    exit 1
fi

include $PWD/debian/modules/preinstallcheck.sh
include $PWD/debian/modules/askquestions.sh
include $PWD/debian/modules/installbasics.sh
include $PWD/debian/modules/installpostfix.sh
include $PWD/debian/modules/installmysql.sh
include $PWD/debian/modules/installmta.sh
include $PWD/debian/modules/installantivirus.sh
include $PWD/debian/modules/installwebserver.sh
include $PWD/debian/modules/installftp.sh
include $PWD/debian/modules/installquota.sh
include $PWD/debian/modules/installbind.sh
include $PWD/debian/modules/installwebstats.sh
include $PWD/debian/modules/installjailkit.sh
include $PWD/debian/modules/installfail2ban.sh
include $PWD/debian/modules/installwebmail.sh
include $PWD/debian/modules/installispconfig.sh
include $PWD/debian/modules/installfix.sh

#---------------------------------------------------------------------
# Main program [ main() ]
#    Run the installer
#---------------------------------------------------------------------

echo "========================================="
echo "ISPConfig 3 System installer"
echo "========================================="
echo
echo "This script will do a nearly unattended intallation of"
echo "all software needed to run ISPConfig 3."
echo "When this script starts running, it'll keep going all the way"
echo "So before you continue, please make sure the following checklist is ok:"
echo
echo "- This is a clean / standard debian installation";
echo "- Internet connection is working properly";
echo
echo "If you're all set, press ENTER to continue or CTRL-C to cancel.."
read DUMMY

if [ -f /etc/debian_version ]; then
  PreInstallCheck 2> /var/log/ispconfig_setup.log
  AskQuestions 
  InstallBasics 2>> /var/log/ispconfig_setup.log
  InstallPostfix 2>> /var/log/ispconfig_setup.log
  InstallMysql 2>> /var/log/ispconfig_setup.log
  InstallMTA 2>> /var/log/ispconfig_setup.log
  InstallAntiVirus 2>> /var/log/ispconfig_setup.log
  InstallWebServer 2>> /var/log/ispconfig_setup.log
  InstallFTP 2>> /var/log/ispconfig_setup.log
  if [ $CFG_QUOTA == "y" ]; then
	InstallQuota 2>> /var/log/ispconfig_setup.log
  fi
  InstallBind 2>> /var/log/ispconfig_setup.log
  InstallWebStats 2>> /var/log/ispconfig_setup.log
  if [ $CFG_JKIT == "y" ]; then
	InstallJailkit 2>> /var/log/ispconfig_setup.log
  fi
  InstallFail2ban 2>> /var/log/ispconfig_setup.log
  InstallWebmail 2>> /var/log/ispconfig_setup.log
  InstallISPConfig 2>> /var/log/ispconfig_setup.log
  InstallFix
  echo -e "${green}Well done ISPConfig installed and configured correctly :D${NC}"
  echo "No you can connect to your ISPConfig installation ad https://$CFG_HOSTNAME_FQDN:8080 or https://IP_ADDRESS:8080"
  echo "You can visit my GitHub profile at https://github.com/servisys/ispconfig_setup/"
  if [ $CFG_WEBSERVER == "nginx" ]; then
  	echo "Phpmyadmin is accessibile at  http://$CFG_HOSTNAME_FQDN:8081/phpmyadmin or http://IP_ADDRESS:8081/phpmyadmin";
	echo "Webmail is accessibile at  http://$CFG_HOSTNAME_FQDN:8081/webmail or http://IP_ADDRESS:8081/webmail";
  fi
else
  echo "${red}Unsupported linux distribution.${NC}"
fi

exit 0

