#---------------------------------------------------------------------
# Function: InstallSQLServer
#    Install and configure SQL Server
#---------------------------------------------------------------------
InstallSQLServer() {
  if [ "$CFG_SQLSERVER" == "MySQL" ]; then
    echo -n "Installing Database server (MySQL)... "
    echo "mysql-server-5.5 mysql-server/root_password password $CFG_MYSQL_ROOT_PWD" | debconf-set-selections
    echo "mysql-server-5.5 mysql-server/root_password_again password $CFG_MYSQL_ROOT_PWD" | debconf-set-selections
    apt_install mysql-client mysql-server
    sed -i 's/bind-address		= 127.0.0.1/#bind-address		= 127.0.0.1/' /etc/mysql/mysql.conf.d/mysqld.cnf
    echo "sql-mode=\"NO_ENGINE_SUBSTITUTION\"" >> /etc/mysql/mysql.conf.d/mysqld.cnf
    echo -e "[${green}DONE${NC}]\n"
    echo -n "Restarting MySQL... "
    service mysql restart
    echo -e "[${green}DONE${NC}]\n"
  
  elif [ "$CFG_SQLSERVER" == "MariaDB" ]; then
  
    echo -n "Installing Database server (MariaDB)... "
    #echo "mariadb-server-10.0 mysql-server/root_password password $CFG_MYSQL_ROOT_PWD" | debconf-set-selections
    #echo "mariadb-server-10.0 mysql-server/root_password_again password $CFG_MYSQL_ROOT_PWD" | debconf-set-selections
    apt_install mariadb-client mariadb-server
    sed -i 's/bind-address		= 127.0.0.1/#bind-address		= 127.0.0.1/' /etc/mysql/mariadb.conf.d/50-server.cnf
    echo -e "[${green}DONE${NC}]\n"
    echo -n "Restarting MariaDB... "
    service mysql restart
    echo -e "[${green}DONE${NC}]\n"
  fi	
}
