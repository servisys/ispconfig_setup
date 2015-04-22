#---------------------------------------------------------------------
# Function: InstallBind
#    Install bind DNS server
#---------------------------------------------------------------------
InstallBind() {
  echo -n "Installing bind... ";
  apt-get -y install bind9 dnsutils > /dev/null 2>&1
  echo -e "${green}done! ${NC}\n"
}
