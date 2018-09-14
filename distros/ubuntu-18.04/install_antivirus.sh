#---------------------------------------------------------------------
# Function: InstallAntiVirus
#    Install Amavisd, Spamassassin, ClamAV
#---------------------------------------------------------------------
InstallAntiVirus() {
  echo -n "Installing Anti-Virus utilities... (This take some time. Don't abort it ...) "
  apt-get -yqq install amavisd-new spamassassin clamav clamav-daemon unzip bzip2 arj nomarch lzop cabextract apt-listchanges libnet-ldap-perl libauthen-sasl-perl clamav-docs daemon libio-string-perl libio-socket-ssl-perl libnet-ident-perl zip libnet-dns-perl rkhunter > /dev/null 2>&1
  sed -i "s/AllowSupplementaryGroups false/AllowSupplementaryGroups true/" /etc/clamav/clamd.conf
  echo -n "Stopping Spamassassin ... "
  service spamassassin stop
  echo -e "[${green}DONE${NC}]\n"
  echo -n "Disable Spamassassin ... "
  update-rc.d -f spamassassin remove
  echo -e "[${green}DONE${NC}]\n"
  #Patch
  echo "Applying patch for Amavis"
  cd /tmp
  wget https://git.ispconfig.org/ispconfig/ispconfig3/raw/stable-3.1/helper_scripts/ubuntu-amavisd-new-2.11.patch
  cd /usr/sbin
  cp -pf amavisd-new amavisd-new_bak
  patch < /tmp/ubuntu-amavisd-new-2.11.patch
  if [ "$CFG_AVUPDATE" == "yes" ]; then
	echo -n "Updating ClamAV. Please Wait ... "
	freshclam
  fi
  echo -n "Restarting ClamAV... "
  service clamav-daemon restart
  echo -e "[${green}DONE${NC}]\n"
}
