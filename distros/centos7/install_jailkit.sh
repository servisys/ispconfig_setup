#---------------------------------------------------------------------
# Function: InstallJailkit
#    Install Jailkit
#---------------------------------------------------------------------

#Program Versions
JKV="2.19"  #Jailkit Version -> Maybe this can be automated

InstallJailkit() {
  # If the jailkit RPM is NOT installed, build from source
  if [ `rpm -q --quiet jailkit` ]
  then
    echo -n "Installing Jailkit... "
    cd /tmp
    wget -q http://olivier.sessink.nl/jailkit/jailkit-$JKV.tar.gz
    tar xvzf jailkit-$JKV.tar.gz
    cd jailkit-$JKV
    ./configure
    make
    make install
    cd ..
    rm -rf jailkit-$JKV
    echo -e "${green}done! ${NC}\n"
  else
    echo -e "Jailkit is already installed...\n"
  fi
}

