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
  
  # Detect currect Linux Version
  # Centos 7 Detection
  . /etc/os-release
  if echo $ID-$VERSION_ID | grep -iq "centos-7"; then
		DISTRO=centos7
  fi

  echo -e "Your Distro is: " $DISTRO
  read -p "Is this correct? (y/n)" -n 1 -r
  echo    # (optional) move to a new line
  if [[ ! $REPLY =~ ^[Yy]$ ]]
  then
    exit 1
  fi

  # Check for already installed ispconfig version
  if [ -f /usr/local/ispconfig/interface/lib/config.inc.php ]; then
    echo "ISPConfig is already installed, can't go on."
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


