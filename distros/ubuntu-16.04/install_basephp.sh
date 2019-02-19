#---------------------------------------------------------------------
# Function: InstallBasePhp Ubuntu 16.04
#    Install Basic php need to run ispconfig
#---------------------------------------------------------------------
InstallBasePhp(){
  echo -n "Installing basic PHP modules... "
  apt_install php7.0-cli php7.0-mysql php7.0-mcrypt mcrypt
  echo -e "[${green}DONE${NC}]\n"
}