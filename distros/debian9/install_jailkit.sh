#---------------------------------------------------------------------
# Function: InstallJailkit
#    Install Jailkit
#---------------------------------------------------------------------

#Program Versions
JKV="2.19"  #Jailkit Version -> Maybe this can be automated

InstallJailkit() {
  echo -n "Installing Jailkit... "
  apt-get -y install build-essential autoconf automake libtool flex bison debhelper binutils > /dev/null 2>&1
  cd /tmp
  wget -q http://olivier.sessink.nl/jailkit/jailkit-$JKV.tar.gz
  tar xfz jailkit-$JKV.tar.gz
  cd jailkit-$JKV
  echo 5 > debian/compat
  ./debian/rules binary > /dev/null 2>&1
  cd ..
  dpkg -i jailkit_$JKV-1_*.deb > /dev/null 2>&1
  rm -rf jailkit-$JKV
  echo -e "[${green}DONE${NC}]\n"
}

