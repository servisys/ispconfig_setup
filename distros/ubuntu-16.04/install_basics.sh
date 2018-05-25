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
  apt-get -yqq install ssh openssh-server vim-nox php7.0-cli ntp ntpdate debconf-utils binutils sudo git lsb-release update-inetd > /dev/null 2>&1
  service apparmor stop 
  update-rc.d -f apparmor remove 
  apt-get -y remove apparmor apparmor-utils

  echo "dash dash/sh boolean false" | debconf-set-selections
  dpkg-reconfigure -f noninteractive dash > /dev/null 2>&1
  echo -n "Reconfigure dash... "
  echo -e "[${green}DONE${NC}]\n"
}
