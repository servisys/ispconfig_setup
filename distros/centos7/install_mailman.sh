#---------------------------------------------------------------------
# Function: InstallMailman
#    Install the Mailman list manager
#---------------------------------------------------------------------
InstallMailman() {
	echo -n "Installing mailman... ";
	yum -y install mailman > /dev/null 2>&1
	/usr/lib/mailman/bin/mmsitepass ${MMSITEPASS}
	/usr/lib/mailman/bin/newlist -q mailman ${MMLISTOWNER} ${MMLISTPASS} | grep '/usr/lib' >> /etc/mailman/aliases
        postalias /etc/mailman/aliases
	# Get mailman in the path so that the ISPConfig installer detects it
	ln -s /usr/lib/mailman/mail/mailman /usr/bin/mailman
	systemctl restart postfix > /dev/null 2>&1
	systemctl enable mailman > /dev/null 2>&1
	systemctl start mailman > /dev/null 2>&1
	echo -e "${green}done! ${NC}\n"
}
