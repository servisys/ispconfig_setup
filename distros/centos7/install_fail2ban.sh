#---------------------------------------------------------------------
# Function: InstallFail2ban
#    Install and configure fail2ban
#---------------------------------------------------------------------
InstallFail2ban() {
  echo -n "Installing fail2ban and rkhunter... "
  yum -y install fail2ban rkhunter > /dev/null 2>&1

cat> /etc/fail2ban/jail.local << EOM
[sshd]
enabled = true
action = iptables[name=sshd, port=ssh, protocol=tcp]

[pure-ftpd]
enabled = true
action = iptables[name=FTP, port=ftp, protocol=tcp]
maxretry = 3

[dovecot]
enabled = true
action = iptables-multiport[name=dovecot, port="pop3,pop3s,imap,imaps", protocol=tcp]
maxretry = 5

[postfix-sasl]
enabled = true
action = iptables-multiport[name=postfix-sasl, port="smtp,smtps,submission", protocol=tcp]
maxretry = 3
EOM

  systemctl enable fail2ban.service
  systemctl start fail2ban.service
 
  echo -e "${green}done! ${NC}\n"
}

