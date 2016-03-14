#---------------------------------------------------------------------
# Function: AskQuestions Debian 8
#    Ask for all needed user input
#---------------------------------------------------------------------
AskQuestions() {
	  CFG_SETUP_WEB=y #Needed for Multiserver setup compatibility
	  CFG_SETUP_MAIL=y #Needed for Multiserver setup compatibility
	  CFG_SETUP_NS=y #Needed for Multiserver setup compatibility
	  echo "Installing pre-required packages"
	  [ -f /bin/whiptail ] && echo -e "whiptail found: ${green}OK${NC}\n"  || apt-get -y install whiptail > /dev/null 2>&1
	  
	  while [ "x$CFG_SQLSERVER" == "x" ]
          do
                CFG_SQLSERVER=$(whiptail --title "SQLSERVER" --backtitle "$WT_BACKTITLE" --nocancel --radiolist "Select SQL Server type" 10 50 2 "MySQL" "(default)" ON "MariaDB" "" OFF 3>&1 1>&2 2>&3)
          done
		  
	  while [ "x$CFG_MYSQL_ROOT_PWD" == "x" ]
	  do
		CFG_MYSQL_ROOT_PWD=$(whiptail --title "MySQL" --backtitle "$WT_BACKTITLE" --inputbox "Please specify a root password" --nocancel 10 50 3>&1 1>&2 2>&3)
	  done

	  while [ "x$CFG_WEBSERVER" == "x" ]
          do
                CFG_WEBSERVER=$(whiptail --title "WEBSERVER" --backtitle "$WT_BACKTITLE" --nocancel --radiolist "Select webserver type" 10 50 2 "apache" "(default)" ON "nginx" "" OFF 3>&1 1>&2 2>&3)
          done
	
	  while [ "x$CFG_XCACHE" == "x" ]
		  do
				CFG_XCACHE=$(whiptail --title "Install XCache" --backtitle "$WT_BACKTITLE" --nocancel --radiolist "You want to install XCache during install? ATTENTION: If XCache is installed, Ioncube Loaders will not work !!" 20 50 2 "yes" "(default)" ON "no" "" OFF 3>&1 1>&2 2>&3)
	  done
	
	  while [ "x$CFG_PHPMYADMIN" == "x" ]
		  do
				CFG_PHPMYADMIN=$(whiptail --title "Install phpMyAdmin" --backtitle "$WT_BACKTITLE" --nocancel --radiolist "You want to install phpMyAdmin during install?" 10 50 2 "yes" "(default)" ON "no" "" OFF 3>&1 1>&2 2>&3)
	  done
	
	  while [ "x$CFG_MTA" == "x" ]
	  do
		CFG_MTA=$(whiptail --title "Mail Server" --backtitle "$WT_BACKTITLE" --nocancel --radiolist "Select mailserver type" 10 50 2 "dovecot" "(default)" ON "courier" "" OFF 3>&1 1>&2 2>&3)
	  done

	  while [ "x$CFG_AVUPDATE" == "x" ]
	  do
		CFG_AVUPDATE=$(whiptail --title "Update Freshclam DB" --backtitle "$WT_BACKTITLE" --nocancel --radiolist "You want to update Antivirus Database during install?" 10 50 2 "yes" "(default)" ON "no" "" OFF 3>&1 1>&2 2>&3)
	  done
	  
	  if (whiptail --title "Quota" --backtitle "$WT_BACKTITLE" --yesno "Setup user quota?" 10 50) then
		CFG_QUOTA=y
	  else
		CFG_QUOTA=n
	  fi
	
	  while [ "x$CFG_ISPC" == "x" ]
	  do
          	CFG_ISPC=$(whiptail --title "ISPConfig Setup" --backtitle "$WT_BACKTITLE" --nocancel --radiolist "Would you like full unattended setup of expert mode for ISPConfig?" 10 50 2 "standard" "(default)" ON "expert" "" OFF 3>&1 1>&2 2>&3)
      done

	  if (whiptail --title "Jailkit" --backtitle "$WT_BACKTITLE" --yesno "Would you like to install Jailkit?" 10 50) then
		CFG_JKIT=y
	  else
		CFG_JKIT=n
	  fi

	  if (whiptail --title "DKIM" --backtitle "$WT_BACKTITLE" --yesno "Would you like to skip DKIM configuration for Amavis?" 10 50) then
		CFG_DKIM=y
	  else
		CFG_DKIM=n
	  fi
	  
	  while [ "x$CFG_WEBMAIL" == "x" ]
	  do
		CFG_WEBMAIL=$(whiptail --title "Webmail client" --backtitle "$WT_BACKTITLE" --nocancel --radiolist "Select your webmail client" 10 50 2 "roundcube" "(default)" ON "squirrelmail" "" OFF 3>&1 1>&2 2>&3)
	  done
	  
	  SSL_COUNTRY=$(whiptail --title "SSL Country" --backtitle "$WT_BACKTITLE" --inputbox "SSL Configuration - Country (ex. EN)" --nocancel 10 50 3>&1 1>&2 2>&3)
      SSL_STATE=$(whiptail --title "SSL State" --backtitle "$WT_BACKTITLE" --inputbox "SSL Configuration - STATE (ex. Italy)" --nocancel 10 50 3>&1 1>&2 2>&3)
      SSL_LOCALITY=$(whiptail --title "SSL Locality" --backtitle "$WT_BACKTITLE" --inputbox "SSL Configuration - Locality (ex. Udine)" --nocancel 10 50 3>&1 1>&2 2>&3)
      SSL_ORGANIZATION=$(whiptail --title "SSL Organization" --backtitle "$WT_BACKTITLE" --inputbox "SSL Configuration - Organization (ex. Company L.t.d.)" --nocancel 10 50 3>&1 1>&2 2>&3)
      SSL_ORGUNIT=$(whiptail --title "SSL Organization Unit" --backtitle "$WT_BACKTITLE" --inputbox "SSL Configuration - Organization Unit (ex. IT Department)" --nocancel 10 50 3>&1 1>&2 2>&3)
}
