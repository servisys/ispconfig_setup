#---------------------------------------------------------------------
# Function: InstallBasics
#    Install basic packages
#---------------------------------------------------------------------
InstallBasics() {
  echo -n "Updating apt and upgrading currently installed packages... "
  apt-get -qq update > /dev/null 2>&1
  apt-get -qqy upgrade > /dev/null 2>&1
  echo -e "[${green}DONE${NC}]\n"

  echo "Installing basic packages... "
  apt-get -y install ssh openssh-server vim-nox ntp ntpdate debconf-utils binutils sudo git lsb-release haveged e2fsprogs > /dev/null 2>&1

  echo "dash dash/sh boolean false" | debconf-set-selections
  dpkg-reconfigure -f noninteractive dash > /dev/null 2>&1
  echo -n "Reconfigure dash... "
  echo -e "[${green}DONE${NC}]\n"
}
