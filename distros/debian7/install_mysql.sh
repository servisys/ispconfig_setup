#---------------------------------------------------------------------
# Function: InstallSQLServer
#    Install and configure SQL Server
#---------------------------------------------------------------------
InstallSQLServer() {
  echo -n "Installing mysql... "
  echo "mysql-server-5.1 mysql-server/root_password password $CFG_MYSQL_ROOT_PWD" | debconf-set-selections
  echo "mysql-server-5.1 mysql-server/root_password_again password $CFG_MYSQL_ROOT_PWD" | debconf-set-selections
  apt-get -y install mysql-client mysql-server > /dev/null 2>&1
  sed -i 's/bind-address		= 127.0.0.1/#bind-address		= 127.0.0.1/' /etc/mysql/my.cnf
  service mysql restart > /dev/null
  echo -e "${green}done! ${NC}\n"
}
