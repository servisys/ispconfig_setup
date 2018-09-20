#---------------------------------------------------------------------
# Function: InstallSQLServer
#    Install and configure SQL Server
#---------------------------------------------------------------------
InstallSQLServer() {
  echo -n "Installing Database server (MySQL)... "
  echo "mysql-server-5.1 mysql-server/root_password password $CFG_MYSQL_ROOT_PWD" | debconf-set-selections
  echo "mysql-server-5.1 mysql-server/root_password_again password $CFG_MYSQL_ROOT_PWD" | debconf-set-selections
  apt_install mysql-client mysql-server
  sed -i 's/bind-address		= 127.0.0.1/#bind-address		= 127.0.0.1/' /etc/mysql/my.cnf
  echo -e "[${green}DONE${NC}]\n"
  echo -n "Restarting MySQL... "
  service mysql restart
  echo -e "[${green}DONE${NC}]\n"
}
