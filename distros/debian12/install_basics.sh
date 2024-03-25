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
  apt_install ssh openssh-server nano vim-nox ntp debconf-utils binutils sudo git lsb-release e2fsprogs
  echo -e "[${green}DONE${NC}]\n"

  if [ /bin/sh -ef /bin/dash ]; then
    echo -n "Changing the default shell from dash to bash... "
    echo "dash dash/sh boolean false" | debconf-set-selections
    dpkg-reconfigure -f noninteractive dash > /dev/null 2>&1
    echo -e "[${green}DONE${NC}]\n"
  fi
}
