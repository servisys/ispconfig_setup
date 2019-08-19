#---------------------------------------------------------------------
# Function: InstallBind
#    Install bind DNS server
#---------------------------------------------------------------------
InstallBind() {
  echo -n "Installing DNS server (Bind)... ";
  apt_install bind9 dnsutils
  echo -e "[${green}DONE${NC}]\n"
  echo -n "Installing haveged... ";
  apt_install haveged
  echo -e "[${green}DONE${NC}]\n"
}
