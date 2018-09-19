#---------------------------------------------------------------------
# Function: InstallJailkit
#    Install Jailkit
#---------------------------------------------------------------------

#Program Versions
JKV="2.19"  #Jailkit Version -> Maybe this can be automated
SUM="f46cac122ac23b1825330d588407aa96"

InstallJailkit() {
  # If the jailkit RPM is NOT installed, build from source
  if [ "$(rpm -q --quiet jailkit)" ]; then
    echo -n "Installing Jailkit... "
    cd /tmp
    wget -q https://olivier.sessink.nl/jailkit/jailkit-$JKV.tar.gz
    if [[ ! "$(md5sum jailkit-$JKV.tar.gz | head -c 32)" = "$SUM" ]]; then
      echo -e "$\n{red}Error: md5sum does not match${NC}" >&2
      echo "Please try running this script again" >&2
      exit 1
    fi
    tar xzf jailkit-$JKV.tar.gz
    cd jailkit-$JKV
    ./configure
    make
    make install
    cd ..
    rm -rf jailkit-$JKV
    echo -e "[${green}DONE${NC}]\n"
  fi
}

