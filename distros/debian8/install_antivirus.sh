#---------------------------------------------------------------------
# Function: InstallAntiVirus
#    Install Amavisd, Spamassassin, ClamAV
#---------------------------------------------------------------------
InstallAntiVirus() {
  echo -n "Installing Anti-Virus utilities... (This take some time. Don't abort it ...) "
  apt-get -yqq install amavisd-new spamassassin clamav clamav-daemon zoo unzip bzip2 arj nomarch lzop cabextract apt-listchanges libnet-ldap-perl libauthen-sasl-perl clamav-docs daemon libio-string-perl libio-socket-ssl-perl libnet-ident-perl zip libnet-dns-perl rkhunter > /dev/null 2>&1
  sed -i "s/AllowSupplementaryGroups false/AllowSupplementaryGroups true/" /etc/clamav/clamd.conf
  echo -n "Stopping Spamassassin ... "
  service spamassassin stop
  echo -e " [${green}done${NC}]\n"
  echo -n "Disable Spamassassin ... "
  systemctl disable spamassassin
  echo -e " [${green}done${NC}]\n"
  service clamav-daemon restart
}
