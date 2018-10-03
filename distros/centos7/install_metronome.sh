#---------------------------------------------------------------------
# Function: InstallMetronome
#    Install metronomeServer
#---------------------------------------------------------------------
InstallMetronome() {
  echo -n "Installing Metronome... ";
  yum_install git lua lua-devel lua-filesystem libidn-devel openssl-devel lua-bitop lua-socket lua-sec luarocks
  luarocks install lpc
  adduser --no-create-home --shell /sbin/nologin --comment 'Metronome' metronome
  cd /opt; git clone https://github.com/maranda/metronome.git metronome
  cd ./metronome; ./configure --ostype=centos --prefix=/usr
  make
  make install
  pushd /etc/metronome/certs && make localhost.key && make localhost.csr && make localhost.cert && chmod 0400 localhost.key && chown metronome localhost.key
  popd
  /bin/rm -rf metronome
  echo -e "[${green}DONE${NC}]\n"
}
