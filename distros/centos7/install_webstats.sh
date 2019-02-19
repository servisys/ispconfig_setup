#---------------------------------------------------------------------
# Function: InstallWebStats
#    Install and configure web stats
#---------------------------------------------------------------------
InstallWebStats() {
  echo -n "Installing Statistics (Webalizer and AWStats)... ";
  yum_install webalizer awstats perl-DateTime-Format-HTTP perl-DateTime-Format-Builder
  echo -e "[${green}DONE${NC}]\n"
}

