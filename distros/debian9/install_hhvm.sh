InstallHHVM() {
  if [ $CFG_SETUP_WEB = "yes" ]; then
    echo -n "Installing HHVM (Hip Hop Virtual Machine)... "
    apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xB4112585D386EB94
    echo deb http://dl.hhvm.com/debian stretch main | tee /etc/apt/sources.list.d/hhvm.list
    hide_output apt-get update
    apt_install hhvm
    echo -e "[${green}DONE${NC}]\n"
  fi
}
