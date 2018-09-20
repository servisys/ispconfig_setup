#---------------------------------------------------------------------
# Function: InstallHHVM
#    Install HHVM
#---------------------------------------------------------------------
InstallHHVM() {
  echo -n "Installing HHVM...) "
  # installs add-apt-repository
  apt-get -y install hhvm
  echo -e "[${green}DONE${NC}]\n"
}
