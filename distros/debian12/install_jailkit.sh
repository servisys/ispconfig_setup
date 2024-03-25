#---------------------------------------------------------------------
# Function: InstallJailkit
#    Install Jailkit
#---------------------------------------------------------------------

#Program Versions
JKV="2.23"  #Jailkit Version -> Maybe this can be automated
SUM="c7018645430248613c6241bf529d95ef"

InstallJailkit() {
  echo -n "Installing Jailkit... "
  apt_install build-essential autoconf automake libtool flex bison debhelper binutils jailkit
  echo -e "[${green}DONE${NC}]\n"
}

