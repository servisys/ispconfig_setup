InstallISPConfigBeta() {
  if [ $CFG_SETUP_WEB = "yes" ]; then
    echo -e "Installing HHVM"
    sudo apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0x5a16e7281be7a449
    echo deb http://dl.hhvm.com/debian jessie main | sudo tee /etc/apt/sources.list.d/hhvm.list
    apt-get update
    apt-get -yqq install hhvm
    echo -e "Installing Lets Encrypt"
    mkdir /opt/certbot
    wget https://dl.eff.org/certbot-auto -O /opt/certbot/certbot-auto
    chmod a+x /opt/certbot/certbot-auto
    /opt/certbot/certbot-auto
  fi
}
