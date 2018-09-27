#---------------------------------------------------------------------
# Function: Install Postfix
#    Install and configure postfix
#---------------------------------------------------------------------
InstallPostfix() {
  echo -n "Disabling Sendmail... "
  systemctl stop sendmail.service
  systemctl disable sendmail.service
  echo -e "[${green}DONE${NC}]\n"
  echo -n "Installing SMTP Mail server (Postfix)... "
  yum_install postfix ntp getmail
  #Fix for mailman virtualtable - need also without mailman
  mkdir /etc/mailman/
  touch /etc/mailman/virtual-mailman
  postmap /etc/mailman/virtual-mailman
  systemctl enable postfix.service
  systemctl restart postfix.service
  echo -e "[${green}DONE${NC}]\n"
}
