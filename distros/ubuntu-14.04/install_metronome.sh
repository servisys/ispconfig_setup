#---------------------------------------------------------------------
# Function: InstallMetronome
#    Install metronomeServer
#---------------------------------------------------------------------
InstallMetronome() {
  echo -n "Installing Metronome... ";
  apt_install git lua5.1 liblua5.1-0-dev lua-filesystem libidn11-dev libssl-dev lua-zlib lua-expat lua-event lua-bitop lua-socket lua-sec luarocks luarocks
  luarocks install lpc
  adduser --no-create-home --disabled-login --gecos 'Metronome' metronome
  cd /opt; git clone https://github.com/maranda/metronome.git metronome
  cd ./metronome; ./configure --ostype=debian --prefix=/usr
  make
  make install
  cd /etc/metronome/certs && make localhost.key && make localhost.csr && make localhost.cert && chmod 0400 localhost.key && chown metronome localhost.key
  echo -e "[${green}DONE${NC}]\n"
}
