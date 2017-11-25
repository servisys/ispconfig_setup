#---------------------------------------------------------------------
# Function: InstallMetronom
#    Install Metronom Server
#---------------------------------------------------------------------
InstallMetronom() {
  echo -n "Installing Metronom.... ";
  echo "deb http://packages.prosody.im/debian stretch main" > /etc/apt/sources.list.d/metronome.list
  wget http://prosody.im/files/prosody-debian-packages.key -O - | sudo apt-key add -
  apt-get -yqq install git lua5.1 liblua5.1-0-dev lua-filesystem libidn11-dev libssl-dev lua-zlib lua-expat lua-event lua-bitop lua-socket lua-sec luarocks luarocks > /dev/null 2>&1
  luarocks install lpc
  adduser --no-create-home --disabled-login --gecos 'Metronome' metronome
  cd /opt; git clone https://github.com/maranda/metronome.git metronome
  cd ./metronome; ./configure --ostype=debian --prefix=/usr
  make
  make install
  echo -e "[${green}DONE${NC}]\n"
}
