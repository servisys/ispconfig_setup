#---------------------------------------------------------------------
# Function: InstallAntiVirus
#    Install Amavisd, Spamassassin, ClamAV
#---------------------------------------------------------------------
InstallAntiVirus() {
  echo -n "Installing Antivirus utilities (Amavisd-new, ClamAV), Spam filtering (SpamAssassin) and Greylisting (Postgrey)... "
  # yum_install amavisd-new spamassassin clamav clamav-server clamav-server-systemd clamav-data-empty clamav-update clamav-unofficial-sigs postgrey unzip bzip2 unrar perl-DBD-mysql
  yum_install amavisd-new spamassassin clamav-server clamav-data clamav-update clamav-filesystem clamav clamav-scanner-systemd clamav-devel clamav-lib clamav-server-systemd unzip bzip2 perl-DBD-mysql postgrey re2c
  sed -i "s/Example/#Example/" /etc/freshclam.conf
  sa-update
  echo -e "[${green}DONE${NC}]\n"
  echo -n "Updating Freshclam Antivirus Database. Please Wait... "
  freshclam 
  systemctl enable amavisd.service
  systemctl start amavisd.service
  systemctl start clamd@amavisd.service
  systemctl enable postgrey.service
  systemctl start postgrey.service
  echo -e "[${green}DONE${NC}]\n"
}
