#---------------------------------------------------------------------
# Function: InstallJailkit
#    Install Jailkit
#---------------------------------------------------------------------

#Program Versions
JKV="2.21"  #Jailkit Version -> Maybe this can be automated
SUM="d316dc22b9f3ab7464c8bd73c2539304"

InstallJailkit() {
  echo -n "Installing Jailkit... "
  apt_install build-essential autoconf automake libtool flex bison debhelper binutils python
  cd /tmp
  wget -q https://olivier.sessink.nl/jailkit/jailkit-$JKV.tar.gz
  if [[ ! "$(md5sum jailkit-$JKV.tar.gz | head -c 32)" = "$SUM" ]]; then
    echo -e "\n${red}Error: md5sum does not match${NC}" >&2
    echo "Please try running this script again" >&2
    exit 1
  fi
  tar xfz jailkit-$JKV.tar.gz
  cd jailkit-$JKV
  echo 5 > debian/compat
  ./debian/rules binary > /dev/null 2>&1
  cd ..
  hide_output dpkg -i jailkit_$JKV-1_*.deb
  rm -rf jailkit-$JKV*
  echo -e "[${green}DONE${NC}]\n"
}

