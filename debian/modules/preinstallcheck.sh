#---------------------------------------------------------------------
# Function: PreInstallCheck
#    Do some pre-install checks
#---------------------------------------------------------------------
PreInstallCheck() {
  echo -n "Checking internet connection.."
  ping -q -c 3 www.ispconfig.org > /dev/null 2>&1

  if [ ! "$?" -eq 0 ]; then
        echo -e "${red}ERROR: Couldn't reach www.ispconfig.org, please check your internet connection${NC}"
        exit 1;
  fi
  
  # Check source.list
  contrib=$(cat /etc/apt/sources.list | grep contrib | grep -v "cdrom")
  nonfree=$(cat /etc/apt/sources.list | grep non-free | grep -v "cdrom")
  if [ -z "$contrib" ]; then
        if [ -z "$nonfree" ]; then
                sed -i 's/main/main contrib non-free/' /etc/apt/sources.list;
        else
                sed -i 's/main/main contrib/' /etc/apt/sources.list;
        fi
  else
        if [ -z "$nonfree" ]; then
                sed -i 's/main/main non-free/' /etc/apt/sources.list;
        fi
  fi
  echo -e "${green}OK${NC}\n"
}

# Detect currect Linux Version

# Debian Wheezy Detection
if command -v lsb_release &> /dev/null; then
	if lsb_release -a 2> /dev/null | grep -iq "wheezy"; then
		DISTRO=wheezy
	fi
fi

# Debian Wheezy Detection
if command -v lsb_release &> /dev/null; then
	if lsb_release -a 2> /dev/null | grep -iq "jessie"; then
		DISTRO=jessie
	fi
fi

# Ubuntu Detection
if command -v lsb_release &> /dev/null; then
	if lsb_release -a 2> /dev/null | grep -iq "ubuntu"; then
		DISTRO=ubuntu
	fi
fi

echo "Your Distro is: " $DISTRO
read -p "Is this correct? (y/n)" -n 1 -r
echo    # (optional) move to a new line
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    exit 1
fi
