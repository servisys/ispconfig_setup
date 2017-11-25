#---------------------------------------------------------------------
# Function: InstallBasePhp Debian 9
#    Install Basic php need to run ispconfig
#---------------------------------------------------------------------
InstallBasePhp(){
  echo -n "Installing basic php modules for ispconfig..."
  apt-get -yqq install php7.0-cli php7.0-mysql php7.0-mcrypt mcrypt > /dev/null 2>&1
  echo -e "[${green}DONE${NC}]\n"
}
