#---------------------------------------------------------------------
# Function: InstallMysql
#    Install and configure mysql
#---------------------------------------------------------------------
InstallSQLServer() {
  echo -n "Installing mysql... "
  yum -y install mariadb-server expect > /dev/null 2>&1
  systemctl enable mariadb.service > /dev/null 2>&1
  systemctl start mariadb.service > /dev/null 2>&1
SECURE_MYSQL=$(expect -c "
set timeout 3
spawn mysql_secure_installation
expect \"Enter current password for root (enter for none):\"
send \"\r\"
expect \"root password?\"
send \"y\r\"
expect \"New password:\"
send \"$CFG_MYSQL_ROOT_PWD\r\"
expect \"Re-enter new password:\"
send \"$CFG_MYSQL_ROOT_PWD\r\"
expect \"Remove anonymous users?\"
send \"y\r\"
expect \"Disallow root login remotely?\"
send \"y\r\"
expect \"Remove test database and access to it?\"
send \"y\r\"
expect \"Reload privilege tables now?\"
send \"y\r\"
expect eof
")
  echo "${SECURE_MYSQL}"
  echo -e "${green}done! ${NC}\n"
}
