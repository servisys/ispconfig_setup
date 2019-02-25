#---------------------------------------------------------------------
# Function: InstallFail2ban
#    Install and configure fail2ban
#---------------------------------------------------------------------
InstallFail2ban() {
  echo -n "Installing Intrusion protection (Fail2Ban)... "
  apt_install fail2ban
  echo -e "[${green}DONE${NC}]\n"
  echo -n "Installing Firewall (UFW)... "
  apt_install ufw

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

[dovecot-pop3imap]
enabled = true
filter = dovecot-pop3imap
action = iptables-multiport[name=dovecot-pop3imap, port="pop3,pop3s,imap,imaps", protocol=tcp]
logpath = /var/log/mail.log
maxretry = 5
EOF

cat > /etc/fail2ban/filter.d/dovecot-pop3imap.conf <<EOF
[Definition]
failregex = (?: pop3-login|imap-login): .*(?:Authentication failure|Aborted login \(auth failed|Aborted login \(tried to use disabled|Disconnected \(auth failed|Aborted login \(\d+ authentication attempts).*rip=(?P<host>\S*),.*
ignoreregex =
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

cat > /etc/fail2ban/filter.d/pureftpd.conf <<EOF
[Definition]
failregex = .*pure-ftpd: \(.*@<HOST>\) \[WARNING\] Authentication failed for user.*
ignoreregex =
EOF

cat > /etc/fail2ban/filter.d/postfix-sasl.conf <<EOF
[Definition]
ignoreregex =

EOF


  echo -e "[${green}DONE${NC}]\n"
  echo -n "Restarting Fail2Ban... "
  service fail2ban restart
  echo -e "[${green}DONE${NC}]\n"
}

