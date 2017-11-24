InstallHHVM() {
  if [ $CFG_SETUP_WEB = "yes" ]; then
    echo -e "Installing HHVM"
    apt-get install -yqq apt-transport-https software-properties-common
    apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xB4112585D386EB94
    add-apt-repository https://dl.hhvm.com/debian
    apt-get update
    apt-get -yqq install hhvm
  fi
}
