#---------------------------------------------------------------------
# Function: InstallWebStats
#    Install and configure web stats
#---------------------------------------------------------------------
InstallWebStats() {
  echo -n "Installing Statistics (Vlogger, Webalizer and AWStats)... ";
  apt_install vlogger webalizer awstats geoip-database libclass-dbi-mysql-perl
  sed -i 's/^/#/' /etc/cron.d/awstats
  echo -e "[${green}DONE${NC}]\n"
}

