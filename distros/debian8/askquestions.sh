#---------------------------------------------------------------------
# Function: AskQuestions
#    Ask for all needed user input
#---------------------------------------------------------------------
AskQuestions() {
	  echo "Installing pre-required packages"
	  [ -f /bin/whiptail ] && echo -e "whiptail found: ${green}OK${NC}\n"  || apt-get -y install whiptail
	  while [ "x$CFG_MYSQL_ROOT_PWD" == "x" ]
	  do
		CFG_MYSQL_ROOT_PWD=$(whiptail --title "MySQL" --backtitle "$WT_BACKTITLE" --inputbox "Please specify a root password" --nocancel 10 50 3>&1 1>&2 2>&3)
	  done

	  while [ "x$CFG_WEBSERVER" == "x" ]
          do
                CFG_WEBSERVER=$(whiptail --title "WEBSERVER" --backtitle "$WT_BACKTITLE" --nocancel --radiolist "Select webserver type" 10 50 2 "apache" "(default)" ON "nginx" "" OFF 3>&1 1>&2 2>&3)
          done
	
	  while [ "x$CFG_MTA" == "x" ]
	  do
		CFG_MTA=$(whiptail --title "Mail Server" --backtitle "$WT_BACKTITLE" --nocancel --radiolist "Select mailserver type" 10 50 2 "dovecot" "(default)" ON "courier" "" OFF 3>&1 1>&2 2>&3)
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

	  if (whiptail --title "DKIM" --backtitle "$WT_BACKTITLE" --yesno "Would you like to skip DKIM configuration for Amavis?" 10 50) then
		CFG_DKIM=y
	  else
		CFG_DKIM=n
	  fi
	  
	  CFG_WEBMAIL=squirrelmail
	  
	  SSL_COUNTRY=$(whiptail --title "SSL Country" --backtitle "$WT_BACKTITLE" --inputbox "SSL Configuration - Country (ex. EN)" --nocancel 10 50 3>&1 1>&2 2>&3)
      SSL_STATE=$(whiptail --title "SSL State" --backtitle "$WT_BACKTITLE" --inputbox "SSL Configuration - STATE (ex. Italy)" --nocancel 10 50 3>&1 1>&2 2>&3)
      SSL_LOCALITY=$(whiptail --title "SSL Locality" --backtitle "$WT_BACKTITLE" --inputbox "SSL Configuration - Locality (ex. Udine)" --nocancel 10 50 3>&1 1>&2 2>&3)
      SSL_ORGANIZATION=$(whiptail --title "SSL Organization" --backtitle "$WT_BACKTITLE" --inputbox "SSL Configuration - Organization (ex. Company L.t.d.)" --nocancel 10 50 3>&1 1>&2 2>&3)
      SSL_ORGUNIT=$(whiptail --title "SSL Organization Unit" --backtitle "$WT_BACKTITLE" --inputbox "SSL Configuration - Organization Unit (ex. IT Department)" --nocancel 10 50 3>&1 1>&2 2>&3)

}

