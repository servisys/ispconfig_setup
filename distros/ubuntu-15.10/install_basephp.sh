#---------------------------------------------------------------------
# Function: InstallBasePhp Ubuntu 15.10
#    Install Basic php need to run ispconfig
#---------------------------------------------------------------------
InstallBasePhp(){
  echo -n "Installing basic PHP modules... "
  apt_install php5-cli php5-mysql php5-mcrypt mcrypt
  echo -e "[${green}DONE${NC}]\n"
}