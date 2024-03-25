#-----------------------------------------------------------------------------
# Function: AskQuestionsCluster Debain 10
#	Ask for all needed user input needed for the possible cluster setup
#-----------------------------------------------------------------------------

AskQuestionsMultiserver(){
	if ! command -v whiptail >/dev/null; then
		echo -n "Installing whiptail... "
		apt_install whiptail
		echo -e "[${green}DONE${NC}]\n"
	fi
	
	# If no SQL client is installed, ask for it, otherwise remote DB check always fail.
	if ! command -v mysql >/dev/null; then
		while [[ ! "$_SQLClient" =~ $RE ]]
		do
			_SQLClient=$(whiptail --title "SQL Server" --backtitle "$WT_BACKTITLE" --nocancel --radiolist "Please select SQL Client type" 10 50 2 "MySQL" "(default)" ON "MariaDB" "" OFF 3>&1 1>&2 2>&3)
		done
		
		if [ "$_SQLClient" == "MySQL" ]; then
			apt_install mysql-client
		elif [ "$_SQLClient" == "MariaDB" ]; then
			apt_install mariadb-client
		fi
	fi

	while [[ ! "$CFG_SQLSERVER" =~ $RE ]]
	do
		CFG_SQLSERVER=$(whiptail --title "SQL Server" --backtitle "$WT_BACKTITLE" --nocancel --radiolist "Please select SQL Server type" 10 50 2 "MySQL" "(default)" ON "MariaDB" "" OFF 3>&1 1>&2 2>&3)
	done

	while [[ ! "$CFG_MYSQL_ROOT_PWD" =~ $RE ]]
	do
		CFG_MYSQL_ROOT_PWD=$(whiptail --title "$CFG_SQLSERVER" --backtitle "$WT_BACKTITLE" --passwordbox "Please specify a root password" --nocancel 10 50 3>&1 1>&2 2>&3)
	done
	if (whiptail --title "Setup Master" --backtitle "$WT_BACKTITLE" --yesno "Do you want to setup a Master server?" 10 50) then
		CFG_SETUP_MASTER=y
	else
		CFG_SETUP_MASTER=n
	fi

	if [ $CFG_SETUP_MASTER == "n" ]; then
		while [[ ! "$CHECK_MASTER_CONNECTION" =~ $RE ]]
		do
			while ! [[ "$CFG_MASTER_FQDN" =~ $RE1 && "$CFG_MASTER_FQDN" =~ $RE2 ]]
			do
				CFG_MASTER_FQDN=$(whiptail --title "$CFG_SQLSERVER" --backtitle "$WT_BACKTITLE" --inputbox "Please specify the master fully qualified domain name (FQDN)" --nocancel 10 50 example.com 3>&1 1>&2 2>&3)
			done

			while [[ ! "$CFG_MASTER_MYSQL_ROOT_PWD" =~ $RE ]]
			do
				CFG_MASTER_MYSQL_ROOT_PWD=$(whiptail --title "$CFG_SQLSERVER" --backtitle "$WT_BACKTITLE" --passwordbox "Please specify the master root password" --nocancel 10 50 3>&1 1>&2 2>&3)
			done

			text="Before you continue, run the following SQL commands on the Master $CFG_SQLSERVER server:

			CREATE USER 'root'@'$(ping -c1 "$CFG_HOSTNAME_FQDN" | grep icmp_seq | grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}')' IDENTIFIED BY '$CFG_MASTER_MYSQL_ROOT_PWD';

			GRANT ALL PRIVILEGES ON * . * TO 'root'@'$(ping -c1 "$CFG_HOSTNAME_FQDN" | grep icmp_seq | grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}')' IDENTIFIED BY '$CFG_MASTER_MYSQL_ROOT_PWD' WITH GRANT OPTION MAX_QUERIES_PER_HOUR 0 MAX_CONNECTIONS_PER_HOUR 0 MAX_UPDATES_PER_HOUR 0 MAX_USER_CONNECTIONS 0 ;

			CREATE USER 'root'@'$CFG_HOSTNAME_FQDN' IDENTIFIED BY '$CFG_MASTER_MYSQL_ROOT_PWD';

			GRANT ALL PRIVILEGES ON * . * TO 'root'@'$CFG_HOSTNAME_FQDN' IDENTIFIED BY '$CFG_MASTER_MYSQL_ROOT_PWD' WITH GRANT OPTION MAX_QUERIES_PER_HOUR 0 MAX_CONNECTIONS_PER_HOUR 0 MAX_UPDATES_PER_HOUR 0 MAX_USER_CONNECTIONS 0 ;

			Press \"OK\" when done
			"

			whiptail --title "$CFG_SQLSERVER commands on Master Server" --msgbox "$text" 25 90

			if (whiptail --title "Install server types" --backtitle "$WT_BACKTITLE" --yesno "Do you want to setup a Web server?" 10 50) then
				CFG_SETUP_WEB=yes
			else
				CFG_SETUP_WEB=no
				CFG_APACHE=n
				CFG_NGINX=n
			fi
			MULTISERVER=y

			if mysql --user=root --password=$CFG_MASTER_MYSQL_ROOT_PWD --host=$CFG_MASTER_FQDN --execute="\q" ; then
				CHECK_MASTER_CONNECTION=true		# If variable is empty, then the connection when fine, so we set true to exit from cycle
			else
				text="Sorry but we cannot connect to the Master $CFG_SQLSERVER server

				- Check that you ran the $CFG_SQLSERVER command to allow remote connection
				- Check that the FQDN is correct
				- Check that the root $CFG_SQLSERVER password is correct"

				whiptail --title "$CFG_SQLSERVER Master Connection Failed" --msgbox "$text" 25 90
			fi
		done
	else
		CFG_SETUP_WEB=yes
		MULTISERVER=n
	fi

	if (whiptail --title "Install server types" --backtitle "$WT_BACKTITLE" --yesno "Do you want to setup a Mail server?" 10 50) then
		CFG_SETUP_MAIL=yes
	else
		CFG_SETUP_MAIL=no
	fi

	if (whiptail --title "Install server types" --backtitle "$WT_BACKTITLE" --yesno "Do you want to setup a Name server?" 10 50) then
		CFG_SETUP_NS=yes
	else
		CFG_SETUP_NS=no
	fi

	if (whiptail --title "Install server types" --backtitle "$WT_BACKTITLE" --yesno "Do you want to setup a Database server?" 10 50) then
		CFG_SETUP_DB=y
	else
		CFG_SETUP_DB=n
	fi

	if [ $CFG_SETUP_WEB == "yes" ]; then
		while [[ ! "$CFG_WEBSERVER" =~ $RE ]]
		do
			CFG_WEBSERVER=$(whiptail --title "Web server" --backtitle "$WT_BACKTITLE" --nocancel --radiolist "Please select Web server type" 10 50 2 "Apache" "(default)" ON "nginx" "" OFF 3>&1 1>&2 2>&3)
		done
		CFG_WEBSERVER=${CFG_WEBSERVER,,}

		if (whiptail --title "Quota" --backtitle "$WT_BACKTITLE" --yesno "Setup user quota?" 10 50) then
			CFG_QUOTA=yes
		else
			CFG_QUOTA=no
		fi

		if (whiptail --title "Jailkit" --backtitle "$WT_BACKTITLE" --yesno "Would you like to install Jailkit (it must be installed before ISPConfig)?" 10 50) then
			CFG_JKIT=yes
		else
			CFG_JKIT=no
		fi

		while [[ ! "$CFG_PHPMYADMIN" =~ $RE ]]
		do
			CFG_PHPMYADMIN=$(whiptail --title "Install phpMyAdmin" --backtitle "$WT_BACKTITLE" --nocancel --radiolist "Do you want to install phpMyAdmin?" 10 50 2 "yes" "(default)" ON "no" "" OFF 3>&1 1>&2 2>&3)
		done

		while [[ ! "$CFG_WEBMAIL" =~ $RE ]]
		do
			CFG_WEBMAIL=$(whiptail --title "Webmail client" --backtitle "$WT_BACKTITLE" --nocancel --radiolist "Please select your webmail client" 10 50 3 "Roundcube" "(default)" ON "SquirrelMail" "" OFF "no" "(Skip)" OFF 3>&1 1>&2 2>&3)
		done
		CFG_WEBMAIL=${CFG_WEBMAIL,,}

		if [ "$CFG_WEBMAIL" == "roundcube" ]; then
			roundcube_db=$(whiptail --title "RoundCube mail client" --backtitle "$WT_BACKTITLE" --inputbox "Please specify the roundcube database name" --nocancel 10 50 3>&1 1>&2 2>&3)
			roundcube_user=$(whiptail --title "RoundCube mail client" --backtitle "$WT_BACKTITLE" --inputbox "Please specify the roundcube user" --nocancel 10 50 "$USER" 3>&1 1>&2 2>&3)
			roundcube_pass=$(whiptail --title "RoundCube mail client" --backtitle "$WT_BACKTITLE" --passwordbox "Please specify the roundcube user password" --nocancel 10 50 3>&1 1>&2 2>&3)
		else
			CFG_WEBMAIL="no";
		fi
	else
		CFG_WEBMAIL="no"
	fi

	if [ $CFG_SETUP_MAIL == "yes" ]; then
		while [[ ! "$CFG_MTA" =~ $RE ]]
		do
			CFG_MTA=$(whiptail --title "Mail Server" --backtitle "$WT_BACKTITLE" --nocancel --radiolist "Please select Mail server type" 10 50 2 "Dovecot" "(default)" ON "Courier" "" OFF 3>&1 1>&2 2>&3)
		done
		CFG_MTA=${CFG_MTA,,}

		while [[ ! "$CFG_AVUPDATE" =~ $RE ]]
		do
			CFG_AVUPDATE=$(whiptail --title "Update Freshclam DB" --backtitle "$WT_BACKTITLE" --nocancel --radiolist "Do you want to update Antivirus Database?" 10 50 2 "yes" "(default)" ON "no" "" OFF 3>&1 1>&2 2>&3)
		done

		if (whiptail --title "DKIM" --backtitle "$WT_BACKTITLE" --yesno "Would you like to skip DomainKeys Identified Mail (DKIM) configuration for Amavis? (not recommended)" 10 50) then
			CFG_DKIM=y
		else
			CFG_DKIM=n
		fi
	else
		CFG_DKIM=y
	fi


	CFG_ISPC=expert
#	CFG_WEBMAIL=squirrelmail

	while [[ ! "$SSL_COUNTRY" =~ $RE ]]
	do
		SSL_COUNTRY=$(whiptail --title "SSL Country" --backtitle "$WT_BACKTITLE" --inputbox "SSL Configuration - Country Name (2 letter code) (ex. EN)" --nocancel 10 50 "${LANG:3:2}" 3>&1 1>&2 2>&3)
	done

	while [[ ! "$SSL_STATE" =~ $RE ]]
	do
		SSL_STATE=$(whiptail --title "SSL State" --backtitle "$WT_BACKTITLE" --inputbox "SSL Configuration - State or Province Name (full name) (ex. Italy)" --nocancel 10 50 3>&1 1>&2 2>&3)
	done

	while [[ ! "$SSL_LOCALITY" =~ $RE ]]
	do
		SSL_LOCALITY=$(whiptail --title "SSL Locality" --backtitle "$WT_BACKTITLE" --inputbox "SSL Configuration - Locality Name (eg, city) (ex. Udine)" --nocancel 10 50 3>&1 1>&2 2>&3)
	done

	while [[ ! "$SSL_ORGANIZATION" =~ $RE ]]
	do
		SSL_ORGANIZATION=$(whiptail --title "SSL Organization" --backtitle "$WT_BACKTITLE" --inputbox "SSL Configuration - Organization Name (eg, company) (ex. Company L.t.d.)" --nocancel 10 50 3>&1 1>&2 2>&3)
	done

	while [[ ! "$SSL_ORGUNIT" =~ $RE ]]
	do
		SSL_ORGUNIT=$(whiptail --title "SSL Organization Unit" --backtitle "$WT_BACKTITLE" --inputbox "SSL Configuration - Organizational Unit Name (eg, section) (ex. IT Department)" --nocancel 10 50 3>&1 1>&2 2>&3)
	done
}
