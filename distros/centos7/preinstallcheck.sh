#---------------------------------------------------------------------
# Function: PreInstallCheck
#	Do some pre-install checks
#---------------------------------------------------------------------
PreInstallCheck() {
	echo -n "Preparing to install... "
	# Check if the FQDN is in /etc/hosts
	if [ "X$(grep -E "[a-z,A-Z,0-9\.\-]{2,}" /etc/hostname |grep -vi "localhost")" == "X" ] ; then
		echo -e "\n${red}Before installing ISPConfig, please read the Preliminary Note at: https://www.howtoforge.com/tutorial/centos-7-server/${NC}"
		exit 1
	fi

	if [ "$(getsebool 2>&1)" != "getsebool:  SELinux is disabled" ]; then
		sed -i "s/SELINUX=enforcing/SELINUX=disabled/" /etc/selinux/config
		sed -i "s/SELINUX=permissive/SELINUX=disabled/" /etc/selinux/config

		echo -e "\n${red}Attention your SELINUX was enabled, we had modified your configuration.${NC}"
		echo -e "${red}Before restart ISPConfig setup please reboot the server.${NC}"
		echo -e "${red}The script will exit to let you reboot the server${NC}"
		echo "Press Enter to exit"
		read DUMMY
		exit 1
	fi

	
	while [[ ! "$CFG_NETWORK" =~ $RE ]]
	do
		CFG_NETWORK=$(whiptail --title "Network" --backtitle "$WT_BACKTITLE" --nocancel --radiolist "Have you already configured the Network? If not, we will invoke network configuration tool for you" 10 50 2 "yes" "(default)" ON "no" "" OFF 3>&1 1>&2 2>&3)
	done
	
	if [ "$CFG_NETWORK" == "no" ]; then
		nmtui
	fi
	
	echo -e "[${green}DONE${NC}]\n"
}


