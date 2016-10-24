#---------------------------------------------------------------------
# Function: InstallSQLServer
#    Install and configure SQL Server
#---------------------------------------------------------------------
InstallSQLServer() {
  if [ "$CFG_SQLSERVER" == "MySQL" ]; then
    echo -n "Installing MySQL... "
    echo "mysql-server-5.5 mysql-server/root_password password $CFG_MYSQL_ROOT_PWD" | debconf-set-selections
    echo "mysql-server-5.5 mysql-server/root_password_again password $CFG_MYSQL_ROOT_PWD" | debconf-set-selections
    apt-get -y install mysql-client mysql-server > /dev/null 2>&1
    sed -i 's/bind-address		= 127.0.0.1/#bind-address		= 127.0.0.1/' /etc/mysql/mysql.conf.d/mysqld.cnf
	echo "sql-mode=\"NO_ENGINE_SUBSTITUTION\"" >> /etc/mysql/mysql.conf.d/mysqld.cnf
    service mysql restart > /dev/null
    echo -e "[${green}DONE${NC}]\n"
  
  else
  
    echo -n "Installing MariaDB 10.1 ... "
    echo "mysql-server-5.5 mysql-server/root_password password $CFG_MYSQL_ROOT_PWD" | debconf-set-selections
    echo "mysql-server-5.5 mysql-server/root_password_again password $CFG_MYSQL_ROOT_PWD" | debconf-set-selections
	echo -n "Adding MariaDB Ubuntu Repro for Version 10.1 ... "
	apt-get -y install software-properties-common > /dev/null 2>&1
	apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xF1656F24C74CD1D8 > /dev/null 2>&1
	add-apt-repository 'deb [arch=amd64,i386,ppc64el] http://ftp.hosteurope.de/mirror/mariadb.org/repo/10.1/ubuntu xenial main' > /dev/null 2>&1
	apt-get update
    apt-get -y install mariadb-client mariadb-server > /dev/null 2>&1
    sed -i 's/bind-address		= 127.0.0.1/#bind-address		= 127.0.0.1/' /etc/mysql/mariadb.conf.d/50-server.cnf
    service mysql restart /dev/null 2>&1
    echo -e "[${green}DONE${NC}]\n"
  fi	
}
