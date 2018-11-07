#---------------------------------------------------------------------
# Function: InstallAntiVirus Ubuntu 16.04
#    Install Amavisd, Spamassassin, ClamAV
#---------------------------------------------------------------------
InstallAntiVirus() {
  echo -n -e "Installing Antivirus utilities (Amavisd-new, ClamAV), Spam filtering (SpamAssassin), Greylisting (Postgrey) and Rootkit detection (rkhunter)... [${red}(THIS MAY TAKE AWHILE. DO NOT ABORT!!!)${NC}]\n"
  apt_install amavisd-new spamassassin clamav clamav-daemon zoo unzip bzip2 arj nomarch lzop cabextract apt-listchanges libnet-ldap-perl libauthen-sasl-perl clamav-docs daemon libio-string-perl libio-socket-ssl-perl libnet-ident-perl zip libnet-dns-perl postgrey rkhunter razor pyzor libmail-dkim-perl
  echo -e "[${green}DONE${NC}]\n"
  
  sed -i "s/AllowSupplementaryGroups false/AllowSupplementaryGroups true/" /etc/clamav/clamd.conf
  echo "\$myhostname = \"$CFG_HOSTNAME_FQDN\";" >> /etc/amavis/conf.d/05-node_id
  echo -n "Stopping SpamAssassin... "
  service spamassassin stop
  echo -e "[${green}DONE${NC}]\n"
  
  echo -n "Disabling SpamAssassin... "
  hide_output update-rc.d -f spamassassin remove
  echo -e "[${green}DONE${NC}]\n"
  
  if [ "$CFG_AVUPDATE" == "yes" ]; then
	echo -n "Updating Freshclam Antivirus Database. Please Wait... "
	freshclam
	echo -e "[${green}DONE${NC}]\n"
  fi
  
  echo -n "Restarting ClamAV... "
  service clamav-daemon restart
  echo -e "[${green}DONE${NC}]\n"
}
