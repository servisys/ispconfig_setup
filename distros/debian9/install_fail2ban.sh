#---------------------------------------------------------------------
# Function: InstallFail2ban
#    Install and configure fail2ban
#---------------------------------------------------------------------
InstallFail2ban() {
  echo -n "Installing fail2ban... "
  apt-get -y install fail2ban > /dev/null 2>&1


  case $CFG_MTA in
	"courier")
cat > /etc/fail2ban/jail.local <<EOF
[courierpop3]
enabled = true
port = pop3
filter = courierpop3
logpath = /var/log/mail.log
maxretry = 5

[courierpop3s]
enabled = true
port = pop3s
filter = courierpop3s
logpath = /var/log/mail.log
maxretry = 5

[courierimap]
enabled = true
port = imap2
filter = courierimap
logpath = /var/log/mail.log
maxretry = 5

[courierimaps]
enabled = true
port = imaps
filter = courierimaps
logpath = /var/log/mail.log
maxretry = 5

EOF

cat > /etc/fail2ban/filter.d/courierpop3.conf <<EOF
[Definition]
failregex = pop3d: LOGIN FAILED.*ip=\[.*:<HOST>\]
ignoreregex =
EOF

cat > /etc/fail2ban/filter.d/courierpop3s.conf <<EOF
[Definition]
failregex = pop3d-ssl: LOGIN FAILED.*ip=\[.*:<HOST>\]
ignoreregex =
EOF

cat > /etc/fail2ban/filter.d/courierimap.conf <<EOF
[Definition]
failregex = imapd: LOGIN FAILED.*ip=\[.*:<HOST>\]
ignoreregex =
EOF

cat > /etc/fail2ban/filter.d/courierimaps.conf <<EOF
[Definition]
failregex = imapd-ssl: LOGIN FAILED.*ip=\[.*:<HOST>\]
ignoreregex =
EOF
	;;
  "dovecot")
cat > /etc/fail2ban/jail.local <<EOF

[dovecot]
enabled = true
filter = dovecot
logpath = /var/log/mail.log
maxretry = 5
EOF
	;;
  esac

cat >> /etc/fail2ban/jail.local <<EOF
[pureftpd]
enabled = true
port = ftp
filter = pureftpd
logpath = /var/log/syslog
maxretry = 3

[postfix-sasl]
enabled = true
port = smtp
filter = postfix-sasl
logpath = /var/log/mail.log
maxretry = 5

EOF

  service fail2ban restart > /dev/null 2>&1
  echo -e "[${green}DONE${NC}]\n"
  
  echo -n "Installing UFW Firewall... "
  apt-get -yqq install ufw
  echo -e "[${green}DONE${NC}]\n"
}

