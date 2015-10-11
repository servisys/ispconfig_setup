#---------------------------------------------------------------------
# Function: Install Postfix
#    Install and configure postfix
#---------------------------------------------------------------------
InstallPostfix() {
  echo -e "Cheking and disabling sendmail...\n"
  systemctl stop sendmail.service > /dev/null 2>&1
  systemctl disable sendmail.service > /dev/null 2>&1
  echo -e "Installing postfix... \n"
  yum -y install postfix ntp getmail > /dev/null 2>&1
  systemctl enable postfix.service > /dev/null 2>&1
  systemctl restart postfix.service > /dev/null 2>&1
  echo -e "${green}done${NC}\n"
}
