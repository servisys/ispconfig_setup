#---------------------------------------------------------------------
# Function: InstallMTA
#    Install chosen MTA. Courier or Dovecot
#---------------------------------------------------------------------
InstallMTA() {
  echo -n "Installing POP3/IMAP Mail server (Dovecot) and Mail signing (OpenDKIM, OpenDMARC)... ";
  apt_install dovecot-imapd dovecot-pop3d dovecot-mysql dovecot-sieve dovecot-lmtpd dovecot-managesieved dovecot-lucene dovecot-antispam opendkim opendkim-tools opendmarc
  echo -e "[${green}DONE${NC}]\n"
}
