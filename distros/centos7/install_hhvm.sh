 echo -n "Installing HHVM HipHop Virtual Machine (FCGI)... "
 yum -y install -y epel-release git zeromq-devel

 yum -y install cpp gcc-c++ cmake psmisc {binutils,boost,jemalloc,numactl}-devel \
 {ImageMagick,sqlite,tbb,bzip2,openldap,readline,elfutils-libelf,gmp,lz4,pcre}-devel \
 lib{xslt,event,yaml,vpx,png,zip,icu,mcrypt,memcached,cap,dwarf}-devel \
 {unixODBC,expat,mariadb}-devel lib{edit,curl,xml2,xslt}-devel \
 glog-devel oniguruma-devel ocaml gperf enca libjpeg-turbo-devel openssl-devel \
 mariadb mariadb-server libc-client make

 rpm -Uvh http://mirrors.linuxeye.com/hhvm-repo/7/x86_64/hhvm-3.15.3-1.el7.centos.x86_64.rpm

# Configure Hhvm (optional)
 ln -s /usr/local/bin/hhvm /bin/hhvm
 mkdir /var/run/hhvm/
sed -i "s%date.timezone = Asia/Calcutta%date.timezone = Europe/Istanbul%" /etc/hhvm/server.ini


 echo "[Unit]" >> /etc/systemd/system/hhvm.service
 echo "Description=HHVM HipHop Virtual Machine (FCGI)" >> /etc/systemd/system/hhvm.service
 echo "After=network.target nginx.service mariadb.service" >> /etc/systemd/system/hhvm.service
 echo "" >> /etc/systemd/system/hhvm.service
 echo "[Service]" >> /etc/systemd/system/hhvm.service
#echo "ExecStart=/usr/local/bin/hhvm --config /etc/hhvm/server.ini --user apache2 --mode daemon -vServer.Type=fastcgi -vServer.FileSocket=/var/run/hhvm/hhvm.sock" >> /etc/systemd/system/hhvm.service
echo "ExecStart=/usr/local/bin/hhvm --config /etc/hhvm/server.ini --user apache2 --mode daemon -vServer.Type=fastcgi -vServer.Port=9009" >> /etc/systemd/system/hhvm.service
#echo "ExecStart=/usr/local/bin/hhvm --config /etc/hhvm/server.ini --user nginx --mode daemon -vServer.Type=fastcgi -vServer.FileSocket=/var/run/hhvm/hhvm.sock" >> /etc/systemd/system/hhvm.service
echo "ExecStart=/usr/local/bin/hhvm --config /etc/hhvm/server.ini --user nginx --mode daemon -vServer.Type=fastcgi -vServer.Port=9010" >> /etc/systemd/system/hhvm.service
#echo "ExecStart=/usr/local/bin/hhvm --config /etc/hhvm/server.hdf --user nobody --mode daemon -vServer.Type=fastcgi -vServer.Port=9009" >> /etc/systemd/system/hhvm.service
echo "" >> /etc/systemd/system/hhvm.service
 echo "[Install]" >> /etc/systemd/system/hhvm.service
 echo "WantedBy=multi-user.target" >> /etc/systemd/system/hhvm.service

systemctl enable hhvm.service
systemctl start hhvm.service

 hhvm --version
 echo -e "[${green}DONE${NC}]\n"
