#---------------------------------------------------------------------
# Function: InstallFTP
#    Install and configure PureFTPd
#---------------------------------------------------------------------
InstallFTP() {
  echo -n "Installing FTP server (Pure-FTPd)... "
  yum_install pure-ftpd
  systemctl enable pure-ftpd.service
  systemctl start pure-ftpd.service
  yum_install openssl
  sed -i 's/# TLS                      1/TLS                      1/' /etc/pure-ftpd/pure-ftpd.conf
  
  mkdir -p /etc/ssl/private/
  openssl req -x509 -nodes -days 3650 -newkey rsa:2048 -keyout /etc/ssl/private/pure-ftpd.pem -out /etc/ssl/private/pure-ftpd.pem -subj "/C=$SSL_COUNTRY/ST=$SSL_STATE/L=$SSL_LOCALITY/O=$SSL_ORGANIZATION/OU=$SSL_ORGUNIT/CN=$CFG_HOSTNAME_FQDN"
  chmod 600 /etc/ssl/private/pure-ftpd.pem
  systemctl restart pure-ftpd.service
  echo -e "[${green}DONE${NC}]\n"
}

