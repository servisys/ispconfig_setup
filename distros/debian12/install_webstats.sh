#---------------------------------------------------------------------
# Function: InstallWebStats
#    Install and configure web stats
#---------------------------------------------------------------------
InstallWebStats() {
  echo -n "Installing Statistics (Webalizer and AWStats)... ";
  # apt_install vlogger webalizer awstats geoip-database libclass-dbi-mysql-perl libtimedate-perl
  #apt_install webalizer awstats geoip-database libclass-dbi-mysql-perl libtimedate-perl
  apt_install awstats geoip-database libclass-dbi-mysql-perl libtimedate-perl
  sed -i 's/^/#/' /etc/cron.d/awstats
  echo -e "[${green}DONE${NC}]\n"
}

