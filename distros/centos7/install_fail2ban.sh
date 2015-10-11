#---------------------------------------------------------------------
# Function: InstallFail2ban
#    Install and configure fail2ban
#---------------------------------------------------------------------
InstallFail2ban() {
  echo -n "Installing fail2ban and rkhunter... "
  yum -y install fail2ban rkhunter > /dev/null 2>&1

  systemctl enable fail2ban.service
  systemctl start fail2ban.service
 
  echo -e "${green}done! ${NC}\n"
}

