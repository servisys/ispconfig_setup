#---------------------------------------------------------------------
# Function: InstallMTA
#    Install chosen MTA. Courier or Dovecot
#---------------------------------------------------------------------
InstallMTA() {
  echo -n "Installing Dovecot... ";
  apt-get -qqy install dovecot-imapd dovecot-pop3d dovecot-sieve dovecot-mysql dovecot-lmtpd opendkim opendkim-tools > /dev/null 2>&1
  echo -e "[${green}DONE${NC}]\n"
}
