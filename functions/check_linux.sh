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
  
  if echo $ID-$VERSION_ID | grep -iq "debian-8"; then
		DISTRO=debian8
		#echo -e "Attention: if you distro is debian Jessie, only Squirrelmail will be supported as Webmail"
  fi

  #---------------------------------------------------------------------
  #    Ubuntu 14.04
  #---------------------------------------------------------------------
  
  if echo $ID-$VERSION_ID | grep -iq "ubuntu-14.04"; then
		DISTRO=ubuntu14.04
  fi

  #---------------------------------------------------------------------
  #    CentOS
  #---------------------------------------------------------------------

  if echo $ID-$VERSION_ID | grep -iq "centos-7"; then
		DISTRO=centos7
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

