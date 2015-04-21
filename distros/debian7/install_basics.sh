#---------------------------------------------------------------------
# Function: InstallBasics
#    Install basic packages
#---------------------------------------------------------------------
InstallBasics() {
  echo -n "Updating apt and upgrading currently installed packages... "
  apt-get -qq update
  apt-get -qqy upgrade
  echo -e "${green}done${NC}"

  echo -n "Installing basic packages... "
  apt-get -y install ssh openssh-server vim-nox ntp ntpdate debconf-utils binutils sudo git lsb-release > /dev/null 2>&1

  echo "dash dash/sh boolean false" | debconf-set-selections
  dpkg-reconfigure -f noninteractive dash > /dev/null 2>&1
  echo -e "Reconfigure dash ${green}done${NC}\n"
}

