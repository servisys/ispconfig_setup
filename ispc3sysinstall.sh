#!/bin/bash
#---------------------------------------------------------------------
# ispc3sysinstall.sh
#
# ISPConfig 3 system installer
#
# Script: ispc3sysinstall.sh
# Version: 1.0
# Author: Mark Stunnenberg <mark@e-rave.nl>
# Description: This script will install all the packages needed to install
# ISPConfig 3 on your server.
#
#
#---------------------------------------------------------------------



#---------------------------------------------------------------------
# Global variables
#---------------------------------------------------------------------
CFG_HOSTNAME_FQDN=`hostname -f`;
WT_BACKTITLE="ISPConfig 3 System Installer from Temporini Matteo"


#---------------------------------------------------------------------
# Function: PreInstallCheck
#    Do some pre-install checks
#---------------------------------------------------------------------
PreInstallCheck() {
  echo -n "Checking internet connection.."
  ping -q -c 3 www.ispconfig.org > /dev/null 2>&1

  if [ ! "$?" -eq 0 ]; then
	echo "ERROR: Couldn't reach www.ispconfig.org, please check your internet connection!"
	exit 1;
  fi
  echo "OK!"
}



#---------------------------------------------------------------------
# Function: AskQuestions
#    Ask for all needed user input
#---------------------------------------------------------------------
AskQuestions() {
  echo "Installing pre-required packages"
  [ -f /bin/whiptail ] && echo "whiptail found: OK"  || apt-get -y install whiptail
  while [ "x$CFG_MYSQL_ROOT_PWD" == "x" ]
  do
	CFG_MYSQL_ROOT_PWD=$(whiptail --title "MySQL" --backtitle "$WT_BACKTITLE" --inputbox "Please specify a root password" --nocancel 10 50 3>&1 1>&2 2>&3)
  done

  while [ "x$CFG_MTA" == "x" ]
  do
	CFG_MTA=$(whiptail --title "Mail Server" --backtitle "$WT_BACKTITLE" --nocancel --radiolist "Select mailserver type" 10 50 2 "courier" "(default)" ON "dovecot" "" OFF 3>&1 1>&2 2>&3)
  done

  if (whiptail --title "Quota" --backtitle "$WT_BACKTITLE" --yesno "Setup user quota?" 10 50) then
	CFG_QUOTA=y
  else
	CFG_QUOTA=n
  fi

  if (whiptail --title "Jailkit" --backtitle "$WT_BACKTITLE" --yesno "Would you like to install Jailkit?" 10 50) then
	CFG_JKIT=y
  else
	CFG_JKIT=n
  fi

  while [ "x$CFG_WEBMAIL" == "x" ]
  do
	CFG_WEBMAIL=$(whiptail --title "Webmail client" --backtitle "$WT_BACKTITLE" --nocancel --radiolist "Select your webmail client" 10 50 2 "roundcube" "(default)" ON "squirrelmail" "" OFF 3>&1 1>&2 2>&3)
  done
}



#---------------------------------------------------------------------
# Function: InstallBasics
#    Install basic packages
#---------------------------------------------------------------------
InstallBasics() {
  echo -n "Updating apt and upgrading currently installed packages.."
  apt-get -qq update
  apt-get -qqy upgrade
  echo "done!"

  echo -n "Installing basic packages.."
  apt-get -y install ssh openssh-server vim-nox ntp ntpdate debconf-utils binutils sudo > /dev/null 2>&1

  echo "dash dash/sh boolean false" | debconf-set-selections
  dpkg-reconfigure -f noninteractive dash > /dev/null 2>&1
  echo "done!"
}



#---------------------------------------------------------------------
# Function: Install Postfix
#    Install and configure postfix
#---------------------------------------------------------------------
InstallPostfix() {
  echo -n "Installing postfix.."
  echo "postfix postfix/main_mailer_type select Internet Site" | debconf-set-selections
  echo "postfix postfix/mailname string $CFG_HOSTNAME_FQDN" | debconf-set-selections
  apt-get -y install postfix postfix-mysql postfix-doc getmail4 > /dev/null 2>&1
  echo "done!"
}



#---------------------------------------------------------------------
# Function: InstallMysql
#    Install and configure mysql
#---------------------------------------------------------------------
InstallMysql() {
  echo -n "Installing mysql.."
  echo "mysql-server-5.1 mysql-server/root_password password $CFG_MYSQL_ROOT_PWD" | debconf-set-selections
  echo "mysql-server-5.1 mysql-server/root_password_again password $CFG_MYSQL_ROOT_PWD" | debconf-set-selections
  apt-get -y install mysql-client mysql-server > /dev/null 2>&1
  sed -i 's/bind-address		= 127.0.0.1/#bind-address		= 127.0.0.1/' /etc/mysql/my.cnf
  service mysql restart > /dev/null
  echo "done!"
}



#---------------------------------------------------------------------
# Function: InstallMTA
#    Install chosen MTA. Courier or Dovecot
#---------------------------------------------------------------------
InstallMTA() {
  case $CFG_MTA in
	"courier")
	  echo -n "Installing courier..";
	  echo "courier-base courier-base/webadmin-configmode boolean false" | debconf-set-selections
	  echo "courier-ssl courier-ssl/certnotice note" | debconf-set-selections
	  apt-get -y install courier-authdaemon courier-authlib-mysql courier-pop courier-pop-ssl courier-imap courier-imap-ssl libsasl2-2 libsasl2-modules libsasl2-modules-sql sasl2-bin libpam-mysql courier-maildrop > /dev/null 2>&1
	  sed -i 's/START=no/START=yes/' /etc/default/saslauthd
	  cd /etc/courier
	  rm -f /etc/courier/imapd.pem
	  rm -f /etc/courier/pop3d.pem
	  rm -f /usr/lib/courier/imapd.pem
	  rm -f /usr/lib/courier/pop3d.pem
	  sed -i "s/CN=localhost/CN=${CFG_HOSTNAME_FQDN}/" /etc/courier/imapd.cnf
	  sed -i "s/CN=localhost/CN=${CFG_HOSTNAME_FQDN}/" /etc/courier/pop3d.cnf
	  mkimapdcert > /dev/null 2>&1
	  mkpop3dcert > /dev/null 2>&1
	  ln -s /usr/lib/courier/imapd.pem /etc/courier/imapd.pem
	  ln -s /usr/lib/courier/pop3d.pem /etc/courier/pop3d.pem
	  service courier-imap-ssl restart > /dev/null
	  service courier-pop-ssl restart > /dev/null
	  service courier-authdaemon restart > /dev/null
	  service saslauthd restart > /dev/null
	  echo "done!"
	  ;;
	"dovecot")
	  echo -n "Installing dovecot..";
	  apt-get -qqy install dovecot-imapd dovecot-pop3d dovecot-sieve dovecot-mysql 2>&1
	  echo "done!"
	  ;;
  esac
}



#---------------------------------------------------------------------
# Function: InstallAntiVirus
#    Install Amavisd, Spamassassin, ClamAV
#---------------------------------------------------------------------
InstallAntiVirus() {
  echo -n "Installing anti-virus utilities.."
  apt-get -y install amavisd-new spamassassin clamav clamav-daemon zoo unzip bzip2 arj nomarch lzop cabextract apt-listchanges libnet-ldap-perl libauthen-sasl-perl clamav-docs daemon libio-string-perl libio-socket-ssl-perl libnet-ident-perl zip libnet-dns-perl > /dev/null 2>&1
  echo "done!"
}



#---------------------------------------------------------------------
# Function: InstallApachePHP
#    Install and configure Apache2, php + modules
#---------------------------------------------------------------------
InstallApachePHP() {
  echo "==========================================================================================="
  echo "Attention: When asked 'Configure database for phpmyadmin with dbconfig-common?' select 'NO'"
  echo "Due to a bug in dbconfig-common, this can't be automated."
  echo "==========================================================================================="
  echo "Press ENTER to continue.."
  read DUMMY

  echo -n "Installing apache.."
  echo "phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2" | debconf-set-selections
# - DISABLED DUE TO A BUG IN DBCONFIG - echo "phpmyadmin phpmyadmin/dbconfig-install boolean false" | debconf-set-selections
  echo "dbconfig-common dbconfig-common/dbconfig-install boolean false" | debconf-set-selections
  apt-get -y install apache2 apache2.2-common apache2-doc apache2-mpm-prefork apache2-utils libexpat1 ssl-cert libapache2-mod-php5 php5 php5-common php5-gd php5-mysql php5-imap php5-cli php5-cgi libapache2-mod-fcgid apache2-suexec php-pear php-auth php5-fpm php5-mcrypt mcrypt php5-imagick imagemagick libapache2-mod-suphp libruby libapache2-mod-ruby libapache2-mod-python php5-curl php5-intl php5-memcache php5-memcached php5-ming php5-ps php5-pspell php5-recode php5-snmp php5-sqlite php5-tidy php5-xmlrpc php5-xsl memcached curl > /dev/null 2>&1  
  apt-get -qqy install phpmyadmin
  a2enmod suexec rewrite ssl actions include dav_fs dav auth_digest > /dev/null 2>&1
  service apache2 restart > /dev/null 2>&1
  echo "done!"
}



#---------------------------------------------------------------------
# Function: InstallFTP
#    Install and configure PureFTPd
#---------------------------------------------------------------------
InstallFTP() {
  echo "Installing pureftpd.."
  echo "pure-ftpd-common pure-ftpd/virtualchroot boolean true" | debconf-set-selections
  apt-get -y install pure-ftpd-common pure-ftpd-mysql > /dev/null 2>&1
  sed -i 's/ftp/\#ftp/' /etc/inetd.conf
  echo 1 > /etc/pure-ftpd/conf/TLS
  mkdir -p /etc/ssl/private/
  echo "==========================================================================================="
  echo "The following questions can be left as default (just press enter), but when"
  echo "asked for 'Common Name', enter your FQDN hostname ($CFG_HOSTNAME_FQDN)."
  echo "==========================================================================================="
  echo "Press ENTER to continue.."
  read DUMMY
  openssl req -x509 -nodes -days 3650 -newkey rsa:2048 -keyout /etc/ssl/private/pure-ftpd.pem -out /etc/ssl/private/pure-ftpd.pem
  chmod 600 /etc/ssl/private/pure-ftpd.pem
  service openbsd-inetd restart > /dev/null 2>&1
  service pure-ftpd-mysql restart > /dev/null 2>&1
  echo "done!"
}



#---------------------------------------------------------------------
# Function: InstallQuota
#    Install and configure of disk quota
#---------------------------------------------------------------------
InstallQuota() {
  echo -n "Installing and initializing quota (this might take while).."
  apt-get -qqy install quota quotatool > /dev/null 2>&1

  if [ `cat /etc/fstab | grep ',usrjquota=aquota.user,grpjquota=aquota.group,jqfmt=vfsv0' | wc -l` -eq 0 ]; then
	sed -i 's/errors=remount-ro/errors=remount-ro,usrjquota=aquota.user,grpjquota=aquota.group,jqfmt=vfsv0/' /etc/fstab
	mount -o remount /
	quotacheck -avugm > /dev/null 2>&1
	quotaon -avug > /dev/null 2>&1
  fi
  echo "done!"
}



#---------------------------------------------------------------------
# Function: InstallBind
#    Install bind DNS server
#---------------------------------------------------------------------
InstallBind() {
  echo -n "Installing bind..";
  apt-get -y install bind9 dnsutils > /dev/null 2>&1
  echo "done!"
}



#---------------------------------------------------------------------
# Function: InstallWebStats
#    Install and configure web stats
#---------------------------------------------------------------------
InstallWebStats() {
  echo -n "Installing stats..";
  apt-get -y install vlogger webalizer awstats > /dev/null 2>&1
  sed -i 's/^/#/' /etc/cron.d/awstats
  echo "done!"
}



#---------------------------------------------------------------------
# Function: InstallJailkit
#    Install Jailkit
#---------------------------------------------------------------------
InstallJailkit() {
  echo -n "Installing jailkit.."
  apt-get -y install build-essential autoconf automake1.9 libtool flex bison debhelper > /dev/null 2>&1
  cd /tmp
  wget -q http://olivier.sessink.nl/jailkit/jailkit-2.14.tar.gz
  tar xfz jailkit-2.14.tar.gz
  cd jailkit-2.14
  ./debian/rules binary > /dev/null 2>&1
  cd ..
  dpkg -i jailkit_2.14-1_*.deb > /dev/null 2>&1
  rm -rf jailkit-2.14*
  echo "done!"
}



#---------------------------------------------------------------------
# Function: InstallFail2ban
#    Install and configure fail2ban
#---------------------------------------------------------------------
InstallFail2ban() {
  echo -n "Installing fail2ban.."
  apt-get -y install fail2ban > /dev/null 2>&1


  case $CFG_MTA in
	"courier")
cat > /etc/fail2ban/jail.local <<EOF
[sasl]
enabled = true
port = smtp
filter = sasl
logpath = /var/log/mail.log
maxretry = 5

[courierpop3]
enabled = true
port = pop3
filter = courierpop3
logpath = /var/log/mail.log
maxretry = 5

[courierpop3s]
enabled = true
port = pop3s
filter = courierpop3s
logpath = /var/log/mail.log
maxretry = 5

[courierimap]
enabled = true
port = imap2
filter = courierimap
logpath = /var/log/mail.log
maxretry = 5

[courierimaps]
enabled = true
port = imaps
filter = courierimaps
logpath = /var/log/mail.log
maxretry = 5

EOF

cat > /etc/fail2ban/filter.d/courierpop3.conf <<EOF
[Definition]
failregex = pop3d: LOGIN FAILED.*ip=\[.*:<HOST>\]
ignoreregex =
EOF

cat > /etc/fail2ban/filter.d/courierpop3s.conf <<EOF
[Definition]
failregex = pop3d-ssl: LOGIN FAILED.*ip=\[.*:<HOST>\]
ignoreregex =
EOF

cat > /etc/fail2ban/filter.d/courierimap.conf <<EOF
[Definition]
failregex = imapd: LOGIN FAILED.*ip=\[.*:<HOST>\]
ignoreregex =
EOF

cat > /etc/fail2ban/filter.d/courierimaps.conf <<EOF
[Definition]
failregex = imapd-ssl: LOGIN FAILED.*ip=\[.*:<HOST>\]
ignoreregex =
EOF
	;;
  "dovecot")
cat > /etc/fail2ban/jail.local <<EOF

[dovecot-pop3imap]
enabled = true
filter = dovecot-pop3imap
action = iptables-multiport[name=dovecot-pop3imap, port="pop3,pop3s,imap,imaps", protocol=tcp]
logpath = /var/log/mail.log
maxretry = 5
EOF

cat > /etc/fail2ban/filter.d/dovecot-pop3imap.conf <<EOF
[Definition]
failregex = (?: pop3-login|imap-login): .*(?:Authentication failure|Aborted login \(auth failed|Aborted login \(tried to use disabled|Disconnected \(auth failed|Aborted login \(\d+ authentication attempts).*rip=(?P<host>\S*),.*
ignoreregex =
EOF
	;;
  esac

cat >> /etc/fail2ban/jail.local <<EOF
[pureftpd]
enabled = true
port = ftp
filter = pureftpd
logpath = /var/log/syslog
maxretry = 3
EOF

cat > /etc/fail2ban/filter.d/pureftpd.conf <<EOF
[Definition]
failregex = .*pure-ftpd: \(.*@<HOST>\) \[WARNING\] Authentication failed for user.*
ignoreregex =
EOF
  service fail2ban restart > /dev/null 2>&1
  echo "done!"
}



#---------------------------------------------------------------------
# Function: InstallWebmail
#    Install the chosen webmail client. Squirrelmail or Roundcube
#---------------------------------------------------------------------
InstallWebmail() {
  echo -n "Installing webmail client ($CFG_WEBMAIL).."
  case $CFG_WEBMAIL in
	"roundcube")
	  RANDPWD=`date +%N%s | md5sum`
	  echo "roundcube-core roundcube/dbconfig-install boolean true" | debconf-set-selections
	  echo "roundcube-core roundcube/database-type select mysql" | debconf-set-selections
	  echo "roundcube-core roundcube/mysql/admin-pass password $CFG_MYSQL_ROOT_PWD" | debconf-set-selections
	  echo "roundcube-core roundcube/db/dbname string roundcube" | debconf-set-selections
	  echo "roundcube-core roundcube/mysql/app-pass password $RANDOMPWD" | debconf-set-selections
	  echo "roundcube-core roundcube/app-password-confirm password $RANDPWD" | debconf-set-selections
	  apt-get -y install roundcube roundcube-mysql git > /dev/null 2>&1
	  sed -i '1iAlias /webmail /var/lib/roundcube' /etc/roundcube/apache.conf
	  sed -i "s/\$rcmail_config\['default_host'\] = '';/\$rcmail_config\['default_host'\] = 'localhost';/" /etc/roundcube/main.inc.php
	  cd /tmp
      git clone https://github.com/w2c/ispconfig3_roundcube.git
      cd /tmp/ispconfig3_roundcube/
      mv ispconfig3_* /var/lib/roundcube/plugins
      cd /var/lib/roundcube/plugins
      mv ispconfig3_account/config/config.inc.php.dist ispconfig3_account/config/config.inc.php
      read -p "If you heaven't done yet add roundcube remtoe user in ISPConfig, with the following permission: Server functions - Client functions - Mail user functions - Mail alias functions - Mail spamfilter user functions - Mail spamfilter policy functions - Mail fetchmail functions - Mail spamfilter whitelist functions - Mail spamfilter blacklist functions - Mail user filter functions"
      wget http://repo.temporini.net/ispconfig_install/roundcube/roundcube.apache -O /etc/apache2/conf.d/roundcube
      wget http://repo.temporini.net/ispconfig_install/roundcube/main.inc.php.txt -O /etc/roundcube/main.inc.php
      nano /var/lib/roundcube/plugins/ispconfig3_account/config/config.inc.php
	;;
	"squirrelmail")
	  echo "dictionaries-common dictionaries-common/default-wordlist select american (American English)" | debconf-set-selections
	  apt-get -y install squirrelmail wamerican > /dev/null 2>&1
	  ln -s /etc/squirrelmail/apache.conf /etc/apache2/conf.d/squirrelmail
	  sed -i 1d /etc/squirrelmail/apache.conf
	  sed -i '1iAlias /webmail /usr/share/squirrelmail' /etc/squirrelmail/apache.conf

	  case $CFG_MTA in
		"courier")
		  sed -i 's/$imap_server_type       = "other";/$imap_server_type       = "courier";/' /etc/squirrelmail/config.php
		  sed -i 's/$optional_delimiter     = "detect";/$optional_delimiter     = ".";/' /etc/squirrelmail/config.php
		  sed -i 's/$default_folder_prefix          = "";/$default_folder_prefix          = "INBOX.";/' /etc/squirrelmail/config.php
		  sed -i 's/$trash_folder                   = "INBOX.Trash";/$trash_folder                   = "Trash";/' /etc/squirrelmail/config.php
		  sed -i 's/$sent_folder                    = "INBOX.Sent";/$sent_folder                    = "Sent";/' /etc/squirrelmail/config.php
		  sed -i 's/$draft_folder                   = "INBOX.Drafts";/$draft_folder                   = "Drafts";/' /etc/squirrelmail/config.php
		  sed -i 's/$default_sub_of_inbox           = true;/$default_sub_of_inbox           = false;/' /etc/squirrelmail/config.php
		  sed -i 's/$delete_folder                  = false;/$delete_folder                  = true;/' /etc/squirrelmail/config.php
		  ;;
		"dovecot")
		  sed -i 's/$imap_server_type       = "other";/$imap_server_type       = "dovecot";/' /etc/squirrelmail/config.php
		  sed -i 's/$trash_folder                   = "INBOX.Trash";/$trash_folder                   = "Trash";/' /etc/squirrelmail/config.php
		  sed -i 's/$sent_folder                    = "INBOX.Sent";/$sent_folder                    = "Sent";/' /etc/squirrelmail/config.php
		  sed -i 's/$draft_folder                   = "INBOX.Drafts";/$draft_folder                   = "Drafts";/' /etc/squirrelmail/config.php
		  sed -i 's/$default_sub_of_inbox           = true;/$default_sub_of_inbox           = false;/' /etc/squirrelmail/config.php
		  sed -i 's/$delete_folder                  = false;/$delete_folder                  = true;/' /etc/squirrelmail/config.php
		  ;;
	  esac
	  ;;
  esac
  service apache2 restart > /dev/null 2>&1
  echo "done!"
}


#---------------------------------------------------------------------
# Function: InstallISPConfig
#    Start the ISPConfig3 intallation script
#---------------------------------------------------------------------
InstallISPConfig() {
  echo "Installing ISPConfig3.."
  echo "=================================================================================="
  echo "As a reminder, the following information is needed for the ISPConfig installation:"
  echo "- Full qualified hostname (FQDN) of the server: $CFG_HOSTNAME_FQDN"
  echo "- MySQL root password: $CFG_MYSQL_ROOT_PWD"
  echo "- Common Name (eg, YOUR name): $CFG_HOSTNAME_FQDN"
  echo "=================================================================================="
  echo ""
  echo "Press ENTER to start the installation.."
  read DUMMY
  cd /tmp
  wget http://www.ispconfig.org/downloads/ISPConfig-3-stable.tar.gz
  tar xfz ISPConfig-3-stable.tar.gz
  cd ispconfig3_install/install/
  php -q install.php
}

#---------------------------------------------------------------------
# Function: InstallFix
#	Start bugfix patch
#---------------------------------------------------------------------
InstallFix() {
  echo "=================================================================================="
  echo "We are now apply some post-install bugfix.."
  echo "=================================================================================="
  echo ""
  echo "Press ENTER to start the installation.." 
  read DUMMY
  wget http://repo.temporini.net/ispconfig_install/apache2/suphp.conf.txt -O /etc/apache2/mods-available/suphp.conf
  /etc/init.d/apache2 reload
  wget http://repo.temporini.net/ispconfig_install/postfix/master.cf -O /etc/postfix/master.cf
  /etc/init.d/postfix restart
  echo "All bugfix are now fixed and all should be working fine"
}

#---------------------------------------------------------------------
# Main program [ main() ]
#    Run the installer
#---------------------------------------------------------------------

echo "========================================="
echo "ISPConfig 3 System installer"
echo "========================================="
echo
echo "This script will do a nearly unattended intallation of"
echo "all software needed to run ISPConfig 3."
echo "When this script starts running, it'll keep going all the way"
echo "So before you continue, please make sure the following checklist is ok:"
echo
echo "- This is a clean / standard debian installation";
echo "- Internet connection is working properly";
echo
echo "If you're all set, press ENTER to continue or CTRL-C to cancel.."
read DUMMY

if [ -f /etc/debian_version ]; then
#  PreInstallCheck
  AskQuestions
  InstallBasics
  InstallPostfix
  InstallMysql
  InstallMTA
  InstallAntiVirus
  InstallApachePHP
  InstallFTP
  if [ $CFG_QUOTA == "y" ]; then
	InstallQuota
  fi
  InstallBind
  InstallWebStats
  if [ $CFG_JKIT == "y" ]; then
	InstallJailkit
  fi
  InstallFail2ban
  InstallWebmail
  InstallISPConfig
else
  echo "Unsupported linux distribution."
fi

exit 0

