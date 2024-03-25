#---------------------------------------------------------------------
# Function: InstallFTP
#    Install and configure PureFTPd
#---------------------------------------------------------------------
InstallFTP() {
  echo -n "Installing FTP server (Pure-FTPd)... "
  echo "pure-ftpd-common pure-ftpd/virtualchroot boolean true" | debconf-set-selections
  apt_install pure-ftpd-common pure-ftpd-mysql
  openssl dhparam -out /etc/ssl/private/pure-ftpd-dhparams.pem 2048
  sed -i 's/ftp/\#ftp/' /etc/inetd.conf
  echo 1 > /etc/pure-ftpd/conf/TLS
  mkdir -p /etc/ssl/private/
  openssl req -x509 -nodes -days 3650 -newkey rsa:2048 -keyout /etc/ssl/private/pure-ftpd.pem -out /etc/ssl/private/pure-ftpd.pem -subj "/C=$SSL_COUNTRY/ST=$SSL_STATE/L=$SSL_LOCALITY/O=$SSL_ORGANIZATION/OU=$SSL_ORGUNIT/CN=$CFG_HOSTNAME_FQDN"
  chmod 600 /etc/ssl/private/pure-ftpd.pem
  echo -e "[${green}DONE${NC}]\n"
  echo -n "Restarting Pure-FTPd... "
  systemctl restart openbsd-inetd
  systemctl restart pure-ftpd-mysql
  echo -e "[${green}DONE${NC}]\n"
}

