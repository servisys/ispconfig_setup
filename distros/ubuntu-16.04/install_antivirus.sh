#---------------------------------------------------------------------
# Function: InstallAntiVirus Ubuntu 16.04
#    Install Amavisd, Spamassassin, ClamAV
#---------------------------------------------------------------------
InstallAntiVirus() {
  echo -n "Installing Anti-Virus & utilities... [${red}(THIS TAKE SOME TIME. DON'T ABORT !!!§{NC}]\n) "
  apt-get -yqq install amavisd-new spamassassin clamav clamav-daemon zoo unzip bzip2 arj nomarch lzop cabextract apt-listchanges libnet-ldap-perl libauthen-sasl-perl clamav-docs daemon libio-string-perl libio-socket-ssl-perl libnet-ident-perl zip libnet-dns-perl postgrey > /dev/null 2>&1
  echo -e "[${green}DONE${NC}]\n"
  
  sed -i "s/AllowSupplementaryGroups false/AllowSupplementaryGroups true/" /etc/clamav/clamd.conf
  echo -n "Stopping Spamassassin ... "
  service spamassassin stop
  echo -e "[${green}DONE${NC}]\n"
  
  echo -n "Disable Spamassassin ... "
  update-rc.d -f spamassassin remove
  echo -e "[${green}DONE${NC}]\n"
  
  if [ "$CFG_AVUPDATE" == "yes" ]; then
	echo -n "Updating ClamAV. Please Wait ... "
	freshclam
  fi
  
  echo -n "Restarting ClamAV... "
  service clamav-daemon restart
  echo -e "[${green}DONE${NC}]\n"
}
