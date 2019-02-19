#---------------------------------------------------------------------
# Function: InstallAntiVirus
#    Install Amavisd, Spamassassin, ClamAV
#---------------------------------------------------------------------
InstallAntiVirus() {
  echo -n "Installing Antivirus utilities (Amavisd-new, ClamAV), Spam filtering (SpamAssassin), Greylisting (Postgrey) and Rootkit detection (rkhunter)... (This may take awhile. Do not abort...) "
  apt_install amavisd-new spamassassin clamav clamav-daemon unzip bzip2 arj nomarch lzop cabextract apt-listchanges libnet-ldap-perl libauthen-sasl-perl clamav-docs daemon libio-string-perl libio-socket-ssl-perl libnet-ident-perl zip libnet-dns-perl postgrey rkhunter razor pyzor libmail-dkim-perl
  echo -e "[${green}DONE${NC}]\n"
  sed -i "s/AllowSupplementaryGroups false/AllowSupplementaryGroups true/" /etc/clamav/clamd.conf
  echo "\$myhostname = \"$CFG_HOSTNAME_FQDN\";" >> /etc/amavis/conf.d/05-node_id
  echo -n "Stopping SpamAssassin... "
  service spamassassin stop
  echo -e "[${green}DONE${NC}]\n"
  echo -n "Disabling SpamAssassin... "
  hide_output update-rc.d -f spamassassin remove
  echo -e "[${green}DONE${NC}]\n"
  #Patch
  echo -n "Applying patch for Amavisd-new... "
  cd /tmp
  wget -q https://git.ispconfig.org/ispconfig/ispconfig3/raw/stable-3.1/helper_scripts/ubuntu-amavisd-new-2.11.patch
  cd /usr/sbin
  cp -pf amavisd-new amavisd-new_bak
  patch < /tmp/ubuntu-amavisd-new-2.11.patch
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
