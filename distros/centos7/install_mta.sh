#---------------------------------------------------------------------
# Function: InstallMTA
#    Install chosen MTA. Courier or Dovecot
#---------------------------------------------------------------------
InstallMTA() {
  case $CFG_MTA in
	"courier")
	  echo -n "Installing courier... ";
	  echo -e "${red}Sorry not configured yet! ${NC}\n"
	  echo "Press ENTER"
	  read DUMMY
	  ;;
	"dovecot")
	  echo -n "Installing dovecot... ";
	  yum -y install dovecot dovecot-mysql dovecot-pigeonhole > /dev/null 2>&1
	  touch /etc/dovecot/dovecot-sql.conf  > /dev/null 2>&1
	  ln -s /etc/dovecot/dovecot-sql.conf /etc/dovecot-sql.conf  > /dev/null 2>&1
	  systemctl enable dovecot > /dev/null 2>&1
      systemctl start dovecot > /dev/null 2>&1
	  echo -e "${green}done! ${NC}\n"
	  ;;
  esac
}
