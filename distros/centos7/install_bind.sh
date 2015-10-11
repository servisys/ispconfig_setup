#---------------------------------------------------------------------
# Function: InstallBind
#    Install bind DNS server
#---------------------------------------------------------------------
InstallBind() {
  echo -n "Installing bind... ";
  yum -y install bind bind-utils > /dev/null 2>&1
  cp /etc/named.conf /etc/named.conf_bak
  echo "options {" > /etc/named.conf
  echo "      listen-on port 53 { any; };" >> /etc/named.conf
  echo "      listen-on-v6 port 53 { any; };" >> /etc/named.conf
  echo "      directory       \"/var/named\";" >> /etc/named.conf
  echo "      dump-file       \"/var/named/data/cache_dump.db\";" >> /etc/named.conf
  echo "      statistics-file \"/var/named/data/named_stats.txt\";" >> /etc/named.conf
  echo "      memstatistics-file \"/var/named/data/named_mem_stats.txt\";" >> /etc/named.conf
  echo "      allow-query     { any; };" >> /etc/named.conf
  echo "      allow-recursion {\"none\";};" >> /etc/named.conf
  echo "      recursion no;" >> /etc/named.conf
  echo "};" >> /etc/named.conf
  echo "logging {" >> /etc/named.conf
  echo "      channel default_debug {" >> /etc/named.conf
  echo "              file \"data/named.run\";" >> /etc/named.conf
  echo "              severity dynamic;" >> /etc/named.conf
  echo "      };" >> /etc/named.conf
  echo "};" >> /etc/named.conf
  echo "zone \".\" IN {" >> /etc/named.conf
  echo "      type hint;" >> /etc/named.conf
  echo "      file \"named.ca\";" >> /etc/named.conf
  echo "};" >> /etc/named.conf
  echo "include \"/etc/named.conf.local\";" >> /etc/named.conf
  touch /etc/named.conf.local
  systemctl enable named.service
  systemctl start named.service

  echo -e "${green}done! ${NC}\n"
}
