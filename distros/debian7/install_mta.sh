#---------------------------------------------------------------------
# Function: InstallMTA
#    Install chosen MTA. Courier or Dovecot
#---------------------------------------------------------------------
InstallMTA() {
  case $CFG_MTA in
	"courier")
	  echo -n "Installing courier... ";
	  echo "courier-base courier-base/webadmin-configmode boolean false" | debconf-set-selections
	  echo "courier-ssl courier-ssl/certnotice note" | debconf-set-selections
	  apt-get -y install courier-authdaemon courier-authlib-mysql courier-pop courier-pop-ssl courier-imap courier-imap-ssl libsasl2-2 libsasl2-modules libsasl2-modules-sql sasl2-bin libpam-mysql courier-maildrop > /dev/null 2>&1
	  sed -i 's/START=no/START=yes/' /etc/default/saslauthd
	  cd /etc/courier
	  rm -f /etc/courier/imapd.pem
	  rm -f /etc/courier/pop3d.pem
	  rm -f /usr/lib/courier/imapd.pem
	  rm -f /usr/lib/courier/pop3d.pem
	  sed -i "s/CN=localhost/CN=${CFG_HOSTNAME_FQDN}/" /etc/courier/imapd.cnf
	  sed -i "s/CN=localhost/CN=${CFG_HOSTNAME_FQDN}/" /etc/courier/pop3d.cnf
	  mkimapdcert > /dev/null 2>&1
	  mkpop3dcert > /dev/null 2>&1
	  ln -s /usr/lib/courier/imapd.pem /etc/courier/imapd.pem
	  ln -s /usr/lib/courier/pop3d.pem /etc/courier/pop3d.pem
	  service courier-imap-ssl restart > /dev/null
	  service courier-pop-ssl restart > /dev/null
	  service courier-authdaemon restart > /dev/null
	  service saslauthd restart > /dev/null
	  echo -e "${green}done! ${NC}\n"
	  ;;
	"dovecot")
	  echo -n "Installing dovecot... ";
	  apt-get -qqy install dovecot-imapd dovecot-pop3d dovecot-sieve dovecot-mysql > /dev/null 2>&1
	  echo -e "${green}done! ${NC}\n"
	  ;;
  esac
}
