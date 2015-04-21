#---------------------------------------------------------------------
# Function: InstallJailkit
#    Install Jailkit
#---------------------------------------------------------------------

#Program Versions
JKV="2.17"  #Jailkit Version -> Maybe this can be automated

InstallJailkit() {
  echo -n "Installing Jailkit... "
  apt-get -y install build-essential autoconf automake1.9 libtool flex bison debhelper > /dev/null 2>&1
  cd /tmp
  wget -q http://olivier.sessink.nl/jailkit/jailkit-$JKV.tar.gz
  tar xfz jailkit-$JKV.tar.gz
  cd jailkit-$JKV
  ./debian/rules binary > /dev/null 2>&1
  cd ..
  dpkg -i jailkit_$JKV-1_*.deb > /dev/null 2>&1
  rm -rf jailkit-$JKV
  echo -e "${green}done! ${NC}\n"
}

