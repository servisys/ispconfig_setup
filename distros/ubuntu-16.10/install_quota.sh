#---------------------------------------------------------------------
# Function: InstallQuota
#    Install and configure of disk quota
#---------------------------------------------------------------------
InstallQuota() {
	echo -n "Installing and initializing Quota (this might take while)... "
	apt-get -qqy install quota quotatool > /dev/null 2>&1

	if ! [ -f /proc/user_beancounters ]; then

		if [ "$(grep -c ',usrjquota=quota.user,grpjquota=quota.group,jqfmt=vfsv0' /etc/fstab)" -eq 0 ]; then
			sed -i '/\/[[:space:]]\+/ {/tmpfs/!s/errors=remount-ro/errors=remount-ro,usrjquota=quota.user,grpjquota=quota.group,jqfmt=vfsv0/}' /etc/fstab
			sed -i '/\/[[:space:]]\+/ {/tmpfs/!s/defaults/defaults,usrjquota=quota.user,grpjquota=quota.group,jqfmt=vfsv0/}' /etc/fstab
		fi
		mount -o remount /
		quotacheck -avugm
		quotaon -avug

	fi
	echo -e "[${green}DONE${NC}]\n"
}
