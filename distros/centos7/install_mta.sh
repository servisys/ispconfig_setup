#---------------------------------------------------------------------
# Function: InstallMTA
#    Install chosen MTA. Courier or Dovecot
#---------------------------------------------------------------------
InstallMTA() {
  case $CFG_MTA in
	"courier")
	  echo -n "Installing POP3/IMAP Mail server (Courier)... ";
	  echo -e "\n${red}Sorry but Courier is not yet supported.${NC}" >&2
	  echo -e "For more information, see this issue: https://github.com/servisys/ispconfig_setup/issues/70\n"
	  echo "Press ENTER"
	  read DUMMY
	  ;;
	"dovecot")
	  echo -n "Installing POP3/IMAP Mail server (Dovecot)... ";
	  yum_install dovecot dovecot-mysql dovecot-pigeonhole
	  touch /etc/dovecot/dovecot-sql.conf
	  ln -s /etc/dovecot/dovecot-sql.conf /etc/dovecot-sql.conf
	  systemctl enable dovecot
      systemctl start dovecot
	  echo -e "[${green}DONE${NC}]\n"
	  ;;
  esac
}
