#---------------------------------------------------------------------
# Function: PreInstallCheck
#    Do some pre-install checks
#---------------------------------------------------------------------
PreInstallCheck() {
  # Check if user is root
  if [ $(id -u) != "0" ]; then
    echo -n "Error: You must be root to run this script, please use the root user to install the software."
    exit 1
  fi
  
  # Check connectivity
  echo -e "Checking internet connection..."
  ping -q -c 3 www.ispconfig.org > /dev/null 2>&1

  if [ ! "$?" -eq 0 ]; then
        echo -e "${red}ERROR: Couldn't reach www.ispconfig.org, please check your internet connection${NC}"
        exit 1;
  fi
  
  # Check for already installed ispconfig version
  if [ -f /usr/local/ispconfig/interface/lib/config.inc.php ]; then
    echo "ISPConfig is already installed, can't go on."
	exit 1
  fi
  
  # Check if the FQDN is in /etc/hosts
  if [ "X$(grep -E "[a-z,A-Z,0-9\.\-]{2,}" /etc/hostname |grep -vi "localhost")" == "X" ] ; then
        echo -e "${red}Before installing ISPConfig, please read the Preliminary Note at https://www.howtoforge.com/tutorial/centos-7-server/"
        exit 1
  fi

  if [ $(getsebool 2>&1) != "getsebool:  SELinux is disabled" ]; then
	
	sed -i "s/SELINUX=enforcing/SELINUX=disabled/" /etc/selinux/config
	sed -i "s/SELINUX=permissive/SELINUX=disabled/" /etc/selinux/config

	echo -e "${red}Attention your SELINUX was enabled, we had modified your configuration.${NC}"
	echo -e "${red}Before restart ISPConfig setup please reboot the server.${NC}"
	echo -e "${red}The script will exit to let you reboot the server${NC}"
	echo "Press Enter to exit"
	read DUMMY
	exit 1
  fi

  
  while [ "x$CFG_NETWORK" == "x" ]
  do
	CFG_NETWORK=$(whiptail --title "NETWORK" --backtitle "$WT_BACKTITLE" --nocancel --radiolist "Have you already configured Network? If not we'll invoke network configuration tool for you" 10 50 2 "yes" "(default)" ON "no" "" OFF 3>&1 1>&2 2>&3)
  done
  
  if [ $CFG_NETWORK == "no" ]; then
		nmtui
  fi
  
  echo -e "${green}OK${NC}\n"
}


