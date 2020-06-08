#---------------------------------------------------------------------
# Function: InstallQuota
#    Install and configure of disk quota
#---------------------------------------------------------------------
InstallQuota() {
	echo -n "Installing Quota... "
	apt_install quota quotatool
	echo -e "[${green}DONE${NC}]\n"
	quotaoff -a

	if ! [ -f /proc/user_beancounters ]; then
		echo -n "Initializing Quota, this may take a while... "
		if [ "$(grep -c ',usrjquota=quota.user,grpjquota=quota.group,jqfmt=vfsv0' /etc/fstab)" -eq 0 ]; then
			sed -i '/\/[[:space:]]\+/ {/tmpfs/!s/errors=remount-ro/errors=remount-ro,usrjquota=quota.user,grpjquota=quota.group,jqfmt=vfsv0/}' /etc/fstab
			sed -i '/\/[[:space:]]\+/ {/tmpfs/!s/defaults/defaults,usrjquota=quota.user,grpjquota=quota.group,jqfmt=vfsv0/}' /etc/fstab
		fi
		mount -o remount /
		# rc.local is deprecated, so following no longer required
		#if ! [ -e /dev/root ]; then
			# Source: https://www.howtoforge.com/community/threads/new-install-jessie-issue-with-quota.71183/#post-342624
		#	ROOT_PARTITION=$(awk '$2~"^/$" {print $1}' /etc/fstab)
		#	ln -s "$ROOT_PARTITION" /dev/root
		#	sed -i "/^exit 0/i ln -s $ROOT_PARTITION \/dev\/root" /etc/rc.local
		#	sed -i '/^exit 0/i \/etc\/init.d\/quota restart\n' /etc/rc.local
		#fi 
		quotacheck -avugm
		quotaon -avug
		echo -e "[${green}DONE${NC}]\n"
	fi
}
