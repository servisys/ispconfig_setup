#---------------------------------------------------------------------
# Function: InstallBasePhp Ubuntu 18.04
#    Install Basic php need to run ispconfig
#---------------------------------------------------------------------
InstallBasePhp(){
  echo -n "Installing basic PHP modules... "
  apt_install php7.2-cli php7.2-mysql mcrypt
  echo -e "[${green}DONE${NC}]\n"
}