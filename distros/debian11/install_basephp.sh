#---------------------------------------------------------------------
# Function: InstallBasePhp Debian 10
#    Install Basic php need to run ispconfig
#---------------------------------------------------------------------
InstallBasePhp(){
  echo -n "Installing basic PHP modules... "
  apt_install php-cli php-mysql php-mcrypt mcrypt php-mbstring
  echo -e "[${green}DONE${NC}]\n"
}
