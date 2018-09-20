#---------------------------------------------------------------------
# Function: InstallHHVM
#    Install HHVM
#---------------------------------------------------------------------
InstallHHVM() {
  echo -n "Installing HHVM (Hip Hop Virtual Machine)... "
  apt-get -y install hhvm
  echo -e "[${green}DONE${NC}]\n"
}
