#---------------------------------------------------------------------
# Function: InstallQuota
#    Install and configure of disk quota
#---------------------------------------------------------------------
InstallQuota() {
	echo -n "Installing Quota... "
	echo -e "\n${red}Sorry but Quota is not yet supported.${NC}" >&2
	echo -e "For more information, see this issue: https://github.com/servisys/ispconfig_setup/issues/69\n"
	return
	yum_install quota
	echo -e "[${green}DONE${NC}]\n"

	if ! [ -f /proc/user_beancounters ]; then
		echo -n "Initializing Quota, this may take awhile... "
		if [ "$(grep -c ',uquota,gquota' /etc/fstab)" -eq 0 ]; then
			sed -i '/\/[[:space:]]\+/ {/tmpfs/!s/errors=remount-ro/errors=remount-ro,uquota,gquota/}' /etc/fstab
			sed -i '/\/[[:space:]]\+/ {/tmpfs/!s/defaults/defaults,uquota,gquota/}' /etc/fstab
		fi
		mount -o remount /
		quotacheck -avugm
		quotaon -avug
		echo -e "[${green}DONE${NC}]\n"
	fi
}
