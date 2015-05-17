#---------------------------------------------------------------------
# Function: CheckLinux
#    Check Installed Linux Version
#---------------------------------------------------------------------

CheckLinux() {

  #Extract information on system
  . /etc/os-release


  #---------------------------------------------------------------------
  #    Debian 7 Wheezy
  #---------------------------------------------------------------------
  
  if echo $ID-$VERSION_ID | grep -iq "debian-7"; then
	DISTRO=debian7
	#echo -e "Attention: Debian Wheezy is OldStable. Please Upgrade to Latest Debian Version with dist-upgrade !!!"
  fi
  

  #---------------------------------------------------------------------
  #    Debian 8 Jessie
  #---------------------------------------------------------------------
  
  if command -v lsb_release &> /dev/null; then
	if lsb_release -a 2> /dev/null | grep -iq "jessie"; then
		DISTRO=debian8
		#echo -e "Attention: if you distro is debian Jessie, only Squirrelmail will be supported as Webmail"
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

  #---------------------------------------------------------------------
  #    CentOS
  #---------------------------------------------------------------------

  if [ -f /etc/centos-release ]; then
    if [ `cat /etc/centos-release | grep 7.0 | wc -l` -ne 0 ]; then
        DISTRO=centos7
    fi
  fi

  # ONLY for Debug..... :)
  #echo -e "Your Distro is: " $DISTRO
  #read -p "Is this correct? (y/n)" -n 1 -r
  #echo    # (optional) move to a new line
  #if [[ ! $REPLY =~ ^[Yy]$ ]]
  #then
  #  exit 1
  #fi

}

