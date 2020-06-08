#!/usr/bin/env bash
#---------------------------------------------------------------------
# install.sh
#
# ISPConfig 3 system installer
#
# Script: install.sh
# Version: 3.0.5
# Author: Matteo Temporini <temporini.matteo@gmail.com>
# Description: This script will install all the packages needed to install
# ISPConfig 3 on your server.
#
#
#---------------------------------------------------------------------

# Bash Colour
red='\e[0;31m'
green='\e[0;32m'
yellow='\e[0;33m'
bold='\e[1m'
underlined='\e[4m'
NC='\e[0m' # No Color
COLUMNS=$(tput cols)

if [[ "$#" -ne 0 ]]; then
	echo -e "Usage: sudo $0" >&2
	exit 1
fi

# Check if user is root
if [[ $(id -u) -ne 0 ]]; then # $EUID
	echo -e "${red}Error: This script must be run as root, please run this script again with the root user or sudo.${NC}" >&2
	exit 1
fi

# Check if on Linux
if ! echo "$OSTYPE" | grep -iq "linux"; then
	echo -e "${red}Error: This script must be run on Linux.${NC}" >&2
	exit 1
fi

# Check memory
TOTAL_PHYSICAL_MEM=$(awk '/^MemTotal:/ {print $2}' /proc/meminfo)
TOTAL_SWAP=$(awk '/^SwapTotal:/ {print $2}' /proc/meminfo)
if [ "$TOTAL_PHYSICAL_MEM" -lt 524288 ]; then
	echo "This machine has: $(printf "%'d" $((TOTAL_PHYSICAL_MEM / 1024))) MiB ($(printf "%'d" $((((TOTAL_PHYSICAL_MEM * 1024) / 1000) / 1000))) MB) memory (RAM)."
	echo -e "\n${red}Error: ISPConfig needs more memory to function properly. Please run this script on a machine with at least 512 MiB memory, 1 GiB (1024 MiB) recommended.${NC}" >&2
	exit 1
fi

# Check connectivity
echo -n "Checking internet connection... "

if ! ping -q -c 3 www.ispconfig.org > /dev/null 2>&1; then
	echo -e "${red}Error: Could not reach www.ispconfig.org, please check your internet connection and run this script again.${NC}" >&2
	exit 1;
fi

echo -e "[${green}DONE${NC}]\n"

# Check for already installed ISPConfig version
if [ -f /usr/local/ispconfig/interface/lib/config.inc.php ]; then
	echo -e "${red}Error: ISPConfig is already installed, cannot go on.${NC}" >&2
	exit 1
fi

#Those lines are for logging purposes
exec > >(tee -i /var/log/ispconfig_setup.log)
exec 2>&1

#---------------------------------------------------------------------
# Global variables
#---------------------------------------------------------------------
CFG_HOSTNAME_FQDN=$(hostname -f); # hostname -A
IP_ADDRESS=( $(hostname -I) );
RE='^2([0-4][0-9]|5[0-5])|1?[0-9][0-9]{1,2}(\.(2([0-4][0-9]|5[0-5])|1?[0-9]{1,2})){3}$'
IPv4_ADDRESS=( $(for i in ${IP_ADDRESS[*]}; do [[ "$i" =~ $RE ]] && echo "$i"; done) )
RE='^[[:xdigit:]]{1,4}(:[[:xdigit:]]{1,4}){7}$'
IPv6_ADDRESS=( $(for i in ${IP_ADDRESS[*]}; do [[ "$i" =~ $RE ]] && echo "$i"; done) )
WT_BACKTITLE="ISPConfig 3 System Installer from Temporini Matteo"

#Saving current directory
APWD=$(pwd);

#---------------------------------------------------------------------
# Load needed functions
#---------------------------------------------------------------------

source $APWD/functions/check_linux.sh
echo -n "Checking your system, please wait... "
CheckLinux
echo -e "[${green}DONE${NC}]\n"

# Adapted from: https://github.com/virtualmin/slib/blob/master/slib.sh#L460
RE='^.+\.localdomain$'
RE1='^.{4,253}$'
RE2='^([[:alnum:]][[:alnum:]\-]{0,61}[[:alnum:]]\.)+[a-zA-Z]{2,63}$'
if [[ $CFG_HOSTNAME_FQDN =~ $RE ]]; then
	echo "The hostname is: $CFG_HOSTNAME_FQDN."
	echo -e "${yellow}Warning: Hostname cannot be *.localdomain.${NC}\n"
elif ! [[ $CFG_HOSTNAME_FQDN =~ $RE1 && $CFG_HOSTNAME_FQDN =~ $RE2 ]]; then
	echo "The hostname is: $CFG_HOSTNAME_FQDN."
	echo -e "${yellow}Warning: Hostname is not a valid fully qualified domain name (FQDN).${NC}\n"
fi
if [[ $CFG_HOSTNAME_FQDN =~ $RE ]] || ! [[ $CFG_HOSTNAME_FQDN =~ $RE1 && $CFG_HOSTNAME_FQDN =~ $RE2 ]]; then
	echo "The IP address is: ${IP_ADDRESS[0]}."
	# Source: https://www.faqforge.com/linux/which-ports-are-used-on-a-ispconfig-3-server-and-shall-be-open-in-the-firewall/
	echo -e "${yellow}Warning: If this system is connected to a router and/or behind a NAT, please be sure that the private (internal) IP address is static before continuing.${NC} For routers, static internal IP addresses are usually assigned via DHCP reservation. See your routers user guide for more info… You will also need to forward some ports depending on what software you choose to install:\n\tTCP Ports\n\t\t20\t- FTP\n\t\t21\t- FTP\n\t\t22\t- SSH/SFTP\n\t\t25\t- Mail (SMTP)\n\t\t53\t- DNS\n\t\t80\t- Web (HTTP)\n\t\t110\t- Mail (POP3)\n\t\t143\t- Mail (IMAP)\n\t\t443\t- Web (HTTPS)\n\t\t465\t- Mail (SMTPS)\n\t\t587\t- Mail (SMTP)\n\t\t993\t- Mail (IMAPS)\n\t\t995\t- Mail (POP3S)\n\t\t3306\t- Database\n\t\t5222\t- Chat (XMPP)\n\t\t8080\t- ISPConfig\n\t\t8081\t- ISPConfig\n\t\t10000\t- ISPConfig\n\n\tUDP Ports\n\t\t53\t- DNS\n\t\t3306\t- Database\n" | fold -s -w "$COLUMNS"
	# read -p "Would you like to update the hostname for this system? (recommended) (y/n) " -n 1 -r
	echo -n "Would you like to update the hostname for this system? (recommended) (y/n) "
	read -n 1 -r
	echo -e "\n"   # (optional) move to a new line
	RE='^[Yy]$'
	if [[ $REPLY =~ $RE ]]; then
		while ! [[ $line =~ $RE1 && $line =~ $RE2 ]]; do
			# read -p "Please enter a fully qualified domain name (FQDN) (e.g. ${HOSTNAME%%.*}.example.com): " -r line
			echo -n "Please enter a fully qualified domain name (FQDN) (e.g. ${HOSTNAME%%.*}.example.com): "
			read -r line
		done
		# hostnamectl set-hostname "$line"
		#subdomain=${line%%.*}
		hostnamectl set-hostname "$line"
		if grep -q "^${IP_ADDRESS[0]}" /etc/hosts; then
			sed -i "s/^${IP_ADDRESS[0]}.*/${IP_ADDRESS[0]}\t$line\t$subdomain/" /etc/hosts
		else
			sed -i "s/^127.0.1.1.*/${IP_ADDRESS[0]}\t$line\t$subdomain/" /etc/hosts
		fi
		CFG_HOSTNAME_FQDN=$(hostname -f); # hostname -A
	fi
fi

#---------------------------------------------------------------------
# Load needed Modules
#---------------------------------------------------------------------

source $APWD/distros/$DISTRO/preinstallcheck.sh
source $APWD/distros/$DISTRO/askquestions.sh

source $APWD/distros/$DISTRO/install_basics.sh
source $APWD/distros/$DISTRO/install_postfix.sh
source $APWD/distros/$DISTRO/install_mysql.sh
source $APWD/distros/$DISTRO/install_mta.sh
source $APWD/distros/$DISTRO/install_antivirus.sh
source $APWD/distros/$DISTRO/install_webserver.sh
source $APWD/distros/$DISTRO/install_hhvm.sh
source $APWD/distros/$DISTRO/install_ftp.sh
source $APWD/distros/$DISTRO/install_quota.sh
source $APWD/distros/$DISTRO/install_bind.sh
source $APWD/distros/$DISTRO/install_webstats.sh
source $APWD/distros/$DISTRO/install_jailkit.sh
source $APWD/distros/$DISTRO/install_fail2ban.sh
source $APWD/distros/$DISTRO/install_webmail.sh
source $APWD/distros/$DISTRO/install_ispconfig.sh
source $APWD/distros/$DISTRO/install_fix.sh

source $APWD/distros/$DISTRO/install_basephp.sh #to remove in feature release
#---------------------------------------------------------------------
# Main program [ main() ]
#	Run the installer
#---------------------------------------------------------------------
clear

echo "Welcome to ISPConfig Setup Script v.3.0.3.1"
echo "This software is developed by Temporini Matteo"
echo "with the support of the community."
echo "You can visit my website at the followings URLs"
echo "http://www.servisys.it http://www.temporini.net"
echo "and contact me with the following information"
echo "contact email/Hangouts: temporini.matteo@gmail.com"
echo "Skype: matteo.temporini"
echo "========================================="
echo "ISPConfig 3 System installer"
echo "========================================="
echo -e "\nThis script will do a nearly unattended installation of"
echo "all software needed to run ISPConfig 3."
echo "When this script starts running, it will keep going all the way"
echo -e "So, before you continue, please make sure the following checklist is ok:\n"
echo "- This is a clean standard clean installation for supported systems";
echo -e "- Internet connection is working properly\n\n";
echo -e "The detected Linux Distribution is:\t${PRETTY_NAME:-$ID-$VERSION_ID}"
if [ -n "$ID_LIKE" ]; then
	echo -e "Related Linux Distributions:\t\t$ID_LIKE"
fi
CPU=( $(sed -n 's/^model name[[:space:]]*: *//p' /proc/cpuinfo | uniq) )
if [ -n "$CPU" ]; then
	echo -e "Processor (CPU):\t\t\t${CPU[*]}"
fi
CPU_CORES=$(nproc --all)
echo -e "CPU Cores:\t\t\t\t$CPU_CORES"
ARCHITECTURE=$(getconf LONG_BIT)
echo -e "Architecture:\t\t\t\t$HOSTTYPE ($ARCHITECTURE-bit)"
echo -e "Total memory (RAM):\t\t\t$(printf "%'d" $((TOTAL_PHYSICAL_MEM / 1024))) MiB ($(printf "%'d" $((((TOTAL_PHYSICAL_MEM * 1024) / 1000) / 1000))) MB)"
echo -e "Total swap space:\t\t\t$(printf "%'d" $((TOTAL_SWAP / 1024))) MiB ($(printf "%'d" $((((TOTAL_SWAP * 1024) / 1000) / 1000))) MB)"
if command -v lspci >/dev/null; then
	GPU=( $(lspci 2>/dev/null | grep -i 'vga\|3d\|2d' | sed -n 's/^.*: //p') )
fi
if [ -n "$GPU" ]; then
	echo -e "Graphics Processor (GPU):\t\t${GPU[*]}"
fi
echo -e "Computer name:\t\t\t\t$HOSTNAME"
echo -e "Hostname:\t\t\t\t$CFG_HOSTNAME_FQDN"
if [ -n "$IPv4_ADDRESS" ]; then
	echo -e "IPv4 address$([[ ${#IPv4_ADDRESS[*]} -gt 1 ]] && echo "es"):\t\t\t\t${IPv4_ADDRESS[*]}"
fi
if [ -n "$IPv6_ADDRESS" ]; then
	echo -e "IPv6 address$([[ ${#IPv6_ADDRESS[*]} -gt 1 ]] && echo "es"):\t\t\t\t${IPv6_ADDRESS[*]}"
fi
TIME_ZONE=$(timedatectl 2>/dev/null | grep -i 'time zone\|timezone' | sed -n 's/^.*: //p')
echo -e "Time zone:\t\t\t\t$TIME_ZONE\n"
if CONTAINER=$(systemd-detect-virt -c); then
	echo -e "Virtualization container:\t\t$CONTAINER\n"
fi
if VM=$(systemd-detect-virt -v); then
	echo -e "Virtual Machine (VM) hypervisor:\t$VM\n"
fi
if uname -r | grep -iq "microsoft"; then
	echo -e "${yellow}Warning: The Windows Subsystem for Linux (WSL) is not yet fully supported by this script.${NC}"
	echo -e "For more information, see this issue: https://github.com/servisys/ispconfig_setup/issues/176\n"
fi
if [ -n "$DISTRO" ]; then
	echo -e "Installing for this Linux Distribution:\t$DISTRO"
	# read -p "Is this correct? (y/n) " -n 1 -r
	echo -n "Is this correct? (y/n) "
	read -n 1 -r
	echo -e "\n"    # (optional) move to a new line
	RE='^[Yy]$'
	if [[ ! $REPLY =~ $RE ]]; then
		exit 1
	fi
else
	echo -e "Sorry but your System is not supported by this script, if you want your system supported " >&2
	echo -e "open an issue on GitHub: https://github.com/servisys/ispconfig_setup/issues" >&2
	if echo "$ID" | grep -iq 'debian\|raspbian\|ubuntu\|centos\|opensuse\|fedora'; then
		echo -e "\nIt is possible that this script will work if you manually set the DISTRO variable to a version of $ID that is supported."
	elif [ -n "$ID_LIKE" ] && echo "$ID_LIKE" | grep -iq 'debian\|raspbian\|ubuntu\|centos\|opensuse\|fedora'; then
		echo -e "\nIt is possible that this script will work if you manually set the DISTRO variable to one of the related Linux distributions that is supported."
	fi
	if echo "$ID" | grep -iq "opensuse"; then
		echo -e "\nYou can use the script here temporary: https://gist.github.com/jniltinho/7734f4879c4469b9a47f3d3eb4ff0bfb"
		echo -e "Adjust it accordingly for your version of $ID and this issue: https://git.ispconfig.org/ispconfig/ispconfig3/issues/5074."
	fi
	exit 1
fi

RE='^.*[^[:space:]]+.*$'
if [ "$DISTRO" == "debian8" ]; then
	while [[ ! "$CFG_ISPCVERSION" =~ $RE ]]
	do
		CFG_ISPCVERSION=$(whiptail --title "ISPConfig Version" --backtitle "$WT_BACKTITLE" --nocancel --radiolist "Select ISPConfig Version you want to install" 10 50 2 "Stable" "(default)" ON "Beta" "" OFF 3>&1 1>&2 2>&3)
	done
fi

if [ "$DISTRO" == "debian8" ]; then
	while [[ ! "$CFG_MULTISERVER" =~ $RE ]]
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
		source $APWD/distros/$DISTRO/askquestions_multiserver.sh
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
		if [ "$CFG_METRONOME" == "yes" ]; then
			source $APWD/distros/$DISTRO/install_metronome.sh
			InstallMetronome
		fi
		if [ "$CFG_WEBMAIL" != "no" ]; then
			InstallWebmail 
		fi
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
		source $APWD/distros/$DISTRO/install_ispconfigbeta.sh
		InstallISPConfigBeta
	fi
	InstallISPConfig
	InstallFix
	echo -e "\n${green}Well done! ISPConfig installed and configured correctly :D${NC} 😃"
	echo -e "\nNow you can access to your ISPConfig installation at: ${underlined}https://$CFG_HOSTNAME_FQDN:8080${NC} or ${underlined}https://${IP_ADDRESS[0]}:8080${NC}"
	echo -e "The default ISPConfig Username is: ${bold}admin${NC}\n\t      and the Password is: ${bold}admin${NC}"
	echo -e "${yellow}Warning: This is a security risk. Please change the default password after your first login.${NC}"
	
	if [ "$CFG_WEBMAIL" == "roundcube" ]; then
		if [ "$DISTRO" != "debian8" ]; then
			echo -e "\n${red}You will need to edit the username and password in /var/lib/roundcube/plugins/ispconfig3_account/config/config.inc.php of the roundcube user, as the one you set in ISPconfig (under System > remote users)${NC}"
		fi
	fi
	if [ "$CFG_WEBSERVER" == "nginx" ]; then
		if [ "$CFG_PHPMYADMIN" == "yes" ]; then
			echo "phpMyAdmin is accessible at: http://$CFG_HOSTNAME_FQDN:8081/phpmyadmin or http://${IP_ADDRESS[0]}:8081/phpmyadmin";
		fi
		if [ "$DISTRO" == "debian8" ] && [ "$CFG_WEBMAIL" == "roundcube" ]; then
			echo "Webmail is accessible at: https://$CFG_HOSTNAME_FQDN/webmail or https://${IP_ADDRESS[0]}/webmail";
		else
			echo "Webmail is accessible at: http://$CFG_HOSTNAME_FQDN:8081/webmail or http://${IP_ADDRESS[0]}:8081/webmail";
		fi
	fi
elif [ -f /etc/redhat-release ]; then # /etc/centos-release
	echo "Attention please, this is the very first version of the script for CentOS $VERSION_ID"
	echo "Please use only for test purpose for now."
	echo -e "${red}Not yet implemented: courier, nginx support${NC}"
	echo -e "${green}Implemented: apache, mysql, bind, postfix, dovecot, roundcube webmail support${NC}"
	echo "Help us to test and implement, press ENTER if you understand what I'm talking about..."
	read DUMMY
	source $APWD/distros/$DISTRO/install_mailman.sh
	PreInstallCheck
	AskQuestions 
	InstallBasics 
	InstallPostfix 
	if [ "$CFG_MAILMAN" == "yes" ]; then
		InstallMailman
	fi
	InstallSQLServer 
	InstallMTA 
	InstallAntiVirus 
	InstallWebServer
	InstallFTP 
	if [ "$CFG_QUOTA" == "yes" ]; then
		InstallQuota 
	fi
	InstallBind 
	InstallWebStats 
	if [ "$CFG_JKIT" == "yes" ]; then
		InstallJailkit 
	fi
	InstallFail2ban 
	if [ "$CFG_METRONOME" == "yes" ]; then
		source $APWD/distros/$DISTRO/install_metronome.sh
		Installmetronome
	fi
	InstallWebmail 
	InstallISPConfig
	#InstallFix
	echo -e "\n\n"
	echo -e "\n${green}Well done! ISPConfig installed and configured correctly :D${NC} 😃"
	echo -e "\nNow you can access to your ISPConfig installation at: ${underlined}https://$CFG_HOSTNAME_FQDN:8080${NC} or ${underlined}https://${IP_ADDRESS[0]}:8080${NC}"
	echo -e "The default ISPConfig Username is: ${bold}admin${NC}\n\t      and the Password is: ${bold}admin${NC}"
	echo -e "${yellow}Warning: This is a security risk. Please change the default password after your first login.${NC}"
	echo -e "\n${red}If you setup Roundcube webmail go to: http://$CFG_HOSTNAME_FQDN/roundcubemail/installer and configure db connection${NC}"
	echo -e "${red}After that disable access to installer in /etc/httpd/conf.d/roundcubemail.conf${NC}"
elif [ -f /etc/SuSE-release ]; then
	echo -e "${red}Unsupported Linux distribution.${NC}" >&2
else
	echo -e "${red}Unsupported Linux distribution.${NC}" >&2
fi

echo -e "\nYou can visit the GitHub repository at: https://github.com/servisys/ispconfig_setup/"
echo "If you need support or have questions, ask here: https://www.howtoforge.com/community/#ispconfig-3.23"
echo "Please report any errors or issues with this auto installer script at: https://github.com/servisys/ispconfig_setup/issues and with ISPConfig at: https://git.ispconfig.org/ispconfig/ispconfig3/issues"
exit 0

