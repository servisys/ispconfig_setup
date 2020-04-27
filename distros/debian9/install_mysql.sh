#---------------------------------------------------------------------
# Function: InstallSQLServer
#    Install and configure SQL Server
#---------------------------------------------------------------------
InstallSQLServer() {
    echo -n "Installing Database server (Mysql)... "
    echo "mysql-server/root_password password $CFG_MYSQL_ROOT_PWD" | debconf-set-selections
    echo "mysql-server/root_password_again password $CFG_MYSQL_ROOT_PWD" | debconf-set-selections
    apt_install mysql-client mysql-server
    sed -i 's/bind-address		= 127.0.0.1/#bind-address		= 127.0.0.1\nsql-mode="NO_ENGINE_SUBSTITUTION"/' /etc/mysql/conf.d/mysql.cnf
    echo "update mysql.user set plugin = 'mysql_native_password' where user='root';" | mysql -u root
	sed -i 's/password =/password = '$CFG_MYSQL_ROOT_PWD'/' /etc/mysql/debian.cnf
	mysql -e "UPDATE mysql.user SET Password = PASSWORD('$CFG_MYSQL_ROOT_PWD') WHERE User = 'root'"
	# Make our changes take effect
	mysql -e "FLUSH PRIVILEGES"
	echo -e "[${green}DONE${NC}]\n"
	echo -n "Restarting Mysql... "
	service mysql restart
    echo -e "[${green}DONE${NC}]\n"
}
