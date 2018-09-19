#---------------------------------------------------------------------
# Function: InstallMailman
#    Install the Mailman list manager
#---------------------------------------------------------------------
InstallMailman() {
	echo -n "Installing Mailman... ";
	yum_install mailman
	/usr/lib/mailman/bin/mmsitepass "${MMSITEPASS}"
	/usr/lib/mailman/bin/newlist -q mailman "${MMLISTOWNER}" "${MMLISTPASS}" | grep '/usr/lib' >> /etc/mailman/aliases
        postalias /etc/mailman/aliases
	# Get mailman in the path so that the ISPConfig installer detects it
	ln -s /usr/lib/mailman/mail/mailman /usr/bin/mailman
	systemctl restart postfix.service
	systemctl enable mailman.service
	systemctl start mailman.service
	echo -e "[${green}DONE${NC}]\n"
}
