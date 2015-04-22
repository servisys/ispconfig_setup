#---------------------------------------------------------------------
# Function: CheckLinux
#    Check Installed Linux Version
#---------------------------------------------------------------------

apt-get -y install lsb-release

CheckLinux() {
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

  # ONLY for Debug..... :)
  echo -e "Your Distro is: " $DISTRO
  read -p "Is this correct? (y/n)" -n 1 -r
  echo    # (optional) move to a new line
  if [[ ! $REPLY =~ ^[Yy]$ ]]
  then
    exit 1
  fi
}

