#---------------------------------------------------------------------
# Function: CheckLinux
#    Check Installed Linux Version
#---------------------------------------------------------------------

CheckLinux() {
if [ -f /etc/debian_version ]; then
  apt-get -y install lsb-release
  echo -n "Checking your installed Linux Version... "
 
  #---------------------------------------------------------------------
  #    Debian 7 Wheezy
  #---------------------------------------------------------------------
  
  if command -v lsb_release &> /dev/null; then
	if lsb_release -a 2> /dev/null | grep -iq "wheezy"; then
		DISTRO=debian7
	fi
  fi

  #---------------------------------------------------------------------
  #    Debian 8 Jessie
  #---------------------------------------------------------------------
  
  if command -v lsb_release &> /dev/null; then
	if lsb_release -a 2> /dev/null | grep -iq "jessie"; then
		DISTRO=debian8
		echo -e "Attention: if you distro is debian Jessie, only Squirrelmail will be supported as Webmail"
	fi
  fi

  #---------------------------------------------------------------------
  #    Ubuntu
  #---------------------------------------------------------------------
  
  if command -v lsb_release &> /dev/null; then
	if lsb_release -a 2> /dev/null | grep -iq "ubuntu"; then
		DISTRO=ubuntu
	fi
  fi
fi

if [ -f /etc/centos-release ]; then
  if [ `cat /etc/centos-release | grep 7.0 | wc -l` -ne 0 ]; then
        DISTRO=centos7
  fi
fi

  # ONLY for Debug..... :)
  echo -e "Your Distro is: " $DISTRO
  read -p "Is this correct? (y/n)" -n 1 -r
  echo    # (optional) move to a new line
  if [[ ! $REPLY =~ ^[Yy]$ ]]
  then
    exit 1
  fi

}

