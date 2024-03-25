#---------------------------------------------------------------------
# Function: InstallAntiVirus
#    Install Amavisd, Spamassassin, ClamAV
#---------------------------------------------------------------------
InstallAntiVirus() {
  echo -n "Installing Antivirus utilities (Amavisd-new, ClamAV), Spam filtering (SpamAssassin), Greylisting (Postgrey) and Rootkit detection (rkhunter)... (This may take awhile. Do not abort it...) "
  apt_install amavisd-new spamassassin clamav clamav-daemon unzip bzip2 arj nomarch lzop cabextract p7zip p7zip-full unrar lrzip apt-listchanges libnet-ldap-perl libauthen-sasl-perl clamav-docs daemon libio-string-perl libio-socket-ssl-perl libnet-ident-perl zip libnet-dns-perl libdbd-mysql-perl postgrey unrar-free unp lz4 liblz4-tool unp
  sed -i "s/AllowSupplementaryGroups false/AllowSupplementaryGroups true/" /etc/clamav/clamd.conf
  echo "use strict;" > /etc/amavis/conf.d/05-node_id
  echo "chomp(\$myhostname = \`hostname --fqdn\`);" >> /etc/amavis/conf.d/05-node_id
  echo "\$myhostname = \"$CFG_HOSTNAME_FQDN\";" >> /etc/amavis/conf.d/05-node_id
  echo "1;" >> /etc/amavis/conf.d/05-node_id
  echo "$CFG_HOSTNAME_FQDN" > /etc/mailname
  echo -e "[${green}DONE${NC}]\n"
  echo -n "Stopping SpamAssassin... "
  systemctl  stop spamd
  echo -e "[${green}DONE${NC}]\n"
  echo -n "Disabling SpamAssassin... "
  hide_output systemctl disable spamd
  echo -e "[${green}DONE${NC}]\n"
  if [ "$CFG_AVUPDATE" == "yes" ]; then
	echo -n "Updating Freshclam Antivirus Database. Please Wait... "
	freshclam
	echo -e "[${green}DONE${NC}]\n"
  fi
  echo -n "Restarting ClamAV... "
  systemctl restart clamav-daemon
  echo -e "[${green}DONE${NC}]\n"
}
