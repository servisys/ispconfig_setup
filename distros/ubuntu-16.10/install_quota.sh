#---------------------------------------------------------------------
# Function: InstallQuota
#    Install and configure of disk quota
#---------------------------------------------------------------------
InstallQuota() {
	echo -n "Installing Quota... "
	apt_install quota quotatool
	echo -e "[${green}DONE${NC}]\n"

	if ! [ -f /proc/user_beancounters ]; then
		echo -n "Initializing Quota, this may take awhile... "
		if [ "$(grep -c ',usrjquota=quota.user,grpjquota=quota.group,jqfmt=vfsv0' /etc/fstab)" -eq 0 ]; then
			sed -i '/\/[[:space:]]\+/ {/tmpfs/!s/errors=remount-ro/errors=remount-ro,usrjquota=quota.user,grpjquota=quota.group,jqfmt=vfsv0/}' /etc/fstab
			sed -i '/\/[[:space:]]\+/ {/tmpfs/!s/defaults/defaults,usrjquota=quota.user,grpjquota=quota.group,jqfmt=vfsv0/}' /etc/fstab
		fi
		mount -o remount /
		quotacheck -avugm
		quotaon -avug
		echo -e "[${green}DONE${NC}]\n"
	fi
}
