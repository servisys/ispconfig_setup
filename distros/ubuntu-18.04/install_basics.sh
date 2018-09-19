#---------------------------------------------------------------------
# Function: InstallBasics
#    Install basic packages
#---------------------------------------------------------------------
InstallBasics() {
  echo -n "Updating apt package database and upgrading currently installed packages... "
  hide_output apt-get update
  # hide_output apt-get -y upgrade
  hide_output apt-get -y dist-upgrade
  hide_output apt-get -y autoremove
  echo -e "[${green}DONE${NC}]\n"

  echo -n "Installing basic packages (OpenSSH server, NTP, binutils, etc.)... "
  # apt_install ssh openssh-server vim-nox php7.2-cli ntp ntpdate debconf-utils binutils sudo git lsb-release
  apt_install ssh openssh-server vim-nox php7.2-cli ntp debconf-utils binutils sudo git lsb-release
  echo -e "[${green}DONE${NC}]\n"
  echo -n "Stopping AppArmor... "
  service apparmor stop 
  echo -e "[${green}DONE${NC}]\n"
  echo -n "Disabling AppArmor... "
  hide_output update-rc.d -f apparmor remove 
  echo -e "[${green}DONE${NC}]\n"
  echo -n "Removing AppArmor... "
  apt_remove apparmor apparmor-utils
  echo -e "[${green}DONE${NC}]\n"

  if [ /bin/sh -ef /bin/dash ]; then
    echo -n "Changing the default shell from dash to bash... "
    echo "dash dash/sh boolean false" | debconf-set-selections
    dpkg-reconfigure -f noninteractive dash > /dev/null 2>&1
    echo -e "[${green}DONE${NC}]\n"
  fi
}
