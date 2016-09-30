#---------------------------------------------------------------------
# Function: InstallBind
#    Install bind DNS server
#---------------------------------------------------------------------
InstallBind() {
  echo -n "Installing Bind9... ";
  apt-get -yqq install bind9 dnsutils > /dev/null 2>&1
  echo -e "[${green}DONE${NC}]\n"
}
