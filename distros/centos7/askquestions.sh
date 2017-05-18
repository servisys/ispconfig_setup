#---------------------------------------------------------------------
# Function: AskQuestions
#    Ask for all needed user input
#---------------------------------------------------------------------
AskQuestions() {
	  echo "Installing pre-required packages"
	  [ -f /bin/whiptail ] && echo -e "whiptail found: ${green}OK${NC}\n"  || yum -y install newt

	  while [ "x$CFG_MYSQL_ROOT_PWD" == "x" ]
	  do
		CFG_MYSQL_ROOT_PWD=$(whiptail --title "MySQL" --backtitle "$WT_BACKTITLE" --inputbox "Please specify a root password" --nocancel 10 50 3>&1 1>&2 2>&3)
	  done

	  while [ "x$CFG_WEBSERVER" == "x" ]
          do
                CFG_WEBSERVER=$(whiptail --title "WEBSERVER" --backtitle "$WT_BACKTITLE" --nocancel --radiolist "Select webserver type" 10 50 2 "apache" "(default)" ON "apache" "" OFF 3>&1 1>&2 2>&3)
          done
	
	  while [ "x$CFG_MTA" == "x" ]
	  do
		CFG_MTA=$(whiptail --title "Mail Server" --backtitle "$WT_BACKTITLE" --nocancel --radiolist "Select mailserver type" 10 50 2 "dovecot" "(default)" ON "dovecot" "" OFF 3>&1 1>&2 2>&3)
	  done
	
	  #if (whiptail --title "Quota" --backtitle "$WT_BACKTITLE" --yesno "Setup user quota?" 10 50) then
	#	CFG_QUOTA=no
	 # else
		#CFG_QUOTA=no
	  #fi
	
	  if (whiptail --title "Jailkit" --backtitle "$WT_BACKTITLE" --yesno "Would you like to install Jailkit?" 10 50) then
		CFG_JKIT=yes
	  else
		CFG_JKIT=no
	  fi

	  if (whiptail --title "DKIM" --backtitle "$WT_BACKTITLE" --yesno "Would you like to skip DKIM configuration for Amavis?" 10 50) then
		CFG_DKIM=y
	  else
		CFG_DKIM=n
	  fi
	  
	  if (whiptail --title "Mailman" --backtitle "$WT_BACKTITLE" --yesno "Would you like to install Mailman?" 10 50) then
		CFG_MAILMAN=yes
		MMSITEPASS=$(whiptail --title "Mailman Site Password" --backtitle "$WT_BACKTITLE" --inputbox "Please specify the Mailman site password" --nocancel 10 50 3>&1 1>&2 2>&3)
		MMLISTOWNER=$(whiptail --title "Mailman Site List Owner" --backtitle "$WT_BACKTITLE" --inputbox "Please specify the Mailman site list owner" --nocancel 10 50 3>&1 1>&2 2>&3)
		MMLISTPASS=$(whiptail --title "Mailman Site List Password" --backtitle "$WT_BACKTITLE" --inputbox "Please specify the Mailman site list password" --nocancel 10 50 3>&1 1>&2 2>&3)
	  else
		CFG_MAILMAN=no
	  fi
	  
	  while [ "x$CFG_WEBMAIL" == "x" ]
	  do
		CFG_WEBMAIL=$(whiptail --title "Webmail client" --backtitle "$WT_BACKTITLE" --nocancel --radiolist "Select your webmail client" 10 50 2 "roundcube" "(default)" ON "squirrelmail" "" OFF 3>&1 1>&2 2>&3)
	  done

	  if [ $CFG_WEBMAIL == roundcube ]; then
		ROUNDCUBE_DB=$(whiptail --title "ROUNDCUBE Database Name" --backtitle "$WT_BACKTITLE" --inputbox "Please specify the roundcube database name" --nocancel 10 50 3>&1 1>&2 2>&3)
		ROUNDCUBE_USER=$(whiptail --title "ROUNDCUBE Database User" --backtitle "$WT_BACKTITLE" --inputbox "Please specify the roundcube database user" --nocancel 10 50 3>&1 1>&2 2>&3)
		ROUNDCUBE_PWD=$(whiptail --title "ROUNDCUBE Database Name" --backtitle "$WT_BACKTITLE" --inputbox "Please specify the roundcube pasword" --nocancel 10 50 3>&1 1>&2 2>&3)
	  fi
	  
      SSL_COUNTRY=$(whiptail --title "SSL Country" --backtitle "$WT_BACKTITLE" --inputbox "SSL Configuration - Country (ex. EN)" --nocancel 10 50 3>&1 1>&2 2>&3)
      SSL_STATE=$(whiptail --title "SSL State" --backtitle "$WT_BACKTITLE" --inputbox "SSL Configuration - STATE (ex. Italy)" --nocancel 10 50 3>&1 1>&2 2>&3)
      SSL_LOCALITY=$(whiptail --title "SSL Locality" --backtitle "$WT_BACKTITLE" --inputbox "SSL Configuration - Locality (ex. Udine)" --nocancel 10 50 3>&1 1>&2 2>&3)
      SSL_ORGANIZATION=$(whiptail --title "SSL Organization" --backtitle "$WT_BACKTITLE" --inputbox "SSL Configuration - Organization (ex. Company L.t.d.)" --nocancel 10 50 3>&1 1>&2 2>&3)
      SSL_ORGUNIT=$(whiptail --title "SSL Organization Unit" --backtitle "$WT_BACKTITLE" --inputbox "SSL Configuration - Organization Unit (ex. IT Department)" --nocancel 10 50 3>&1 1>&2 2>&3)

}

