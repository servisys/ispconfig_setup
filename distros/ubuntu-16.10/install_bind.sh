#---------------------------------------------------------------------
# Function: InstallBind
#    Install bind DNS server
#---------------------------------------------------------------------
InstallBind() {
  echo -n "Installing DNS server (Bind)... ";
  apt_install bind9 dnsutils haveged
  echo -e "[${green}DONE${NC}]\n"
}
