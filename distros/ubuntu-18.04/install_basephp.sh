#---------------------------------------------------------------------
# Function: InstallBasePhp Ubuntu 18.04
#    Install Basic php need to run ispconfig
#---------------------------------------------------------------------
InstallBasePhp(){
  echo -n "Installing basic php modules for ispconfig..."
  apt-get -yqq install php7.2-cli php7.2-mysql php7.2-mcrypt mcrypt > /dev/null 2>&1
  echo -e "[${green}DONE${NC}]\n"
}