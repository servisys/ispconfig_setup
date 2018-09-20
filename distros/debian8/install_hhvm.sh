InstallHHVM() {
  if [ $CFG_SETUP_WEB = "yes" ]; then
    echo -n "Installing HHVM (Hip Hop Virtual Machine)... "
    apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0x5a16e7281be7a449
    echo deb http://dl.hhvm.com/debian jessie main | tee /etc/apt/sources.list.d/hhvm.list
    hide_output apt-get update
    apt_install hhvm
	echo -e "[${green}DONE${NC}]\n"
  fi
}
