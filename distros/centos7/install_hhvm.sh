InstallHHVM() {
  if [ $CFG_HHVM = "yes" ]; then
echo -n "Installing HHVM HipHop Virtual Machine (FCGI)... "

touch /etc/yum.repos.d/hhvm.repo
echo "[hhvm]" >> /etc/yum.repos.d/hhvm.repo
echo "name=gleez hhvm-repo" >> /etc/yum.repos.d/hhvm.repo
echo "baseurl=http://mirrors.linuxeye.com/hhvm-repo/7/\$basearch/" >> /etc/yum.repos.d/hhvm.repo
echo "enabled=1" >> /etc/yum.repos.d/hhvm.repo
echo "gpgcheck=0" >> /etc/yum.repos.d/hhvm.repo

 yum -y install zeromq-devel hhvm

# Configure Hhvm (optional)
 ln -s /usr/local/bin/hhvm /bin/hhvm
 mkdir /var/run/hhvm/
# Change the admin port (optional)
sed -i "s/hhvm.server.port = 9001/hhvm.server.port = 9011/" /etc/hhvm/server.ini
sed -i "s%date.timezone = Asia/Calcutta%date.timezone = $TIME_ZONE%" /etc/hhvm/server.ini

touch /etc/systemd/system/hhvm.service
 echo "[Unit]" >> /etc/systemd/system/hhvm.service
 echo "Description=HHVM HipHop Virtual Machine (FCGI)" >> /etc/systemd/system/hhvm.service
 echo "After=network.target nginx.service mariadb.service" >> /etc/systemd/system/hhvm.service
 echo "" >> /etc/systemd/system/hhvm.service
 echo "[Service]" >> /etc/systemd/system/hhvm.service

echo "ExecStart=/usr/local/bin/hhvm --config /etc/hhvm/server.ini --user apache --mode daemon -vServer.Type=fastcgi -vServer.Port=9010" >> /etc/systemd/system/hhvm.service

echo "" >> /etc/systemd/system/hhvm.service
 echo "[Install]" >> /etc/systemd/system/hhvm.service
 echo "WantedBy=multi-user.target" >> /etc/systemd/system/hhvm.service

systemctl enable hhvm.service
systemctl daemon-reload

 hhvm --version
 echo -e "[${green}DONE${NC}]\n"
 fi
}
