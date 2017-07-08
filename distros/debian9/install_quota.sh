#---------------------------------------------------------------------
# Function: InstallQuota
#    Install and configure of disk quota
#---------------------------------------------------------------------
InstallQuota() {
  echo -n "Installing and initializing Quota (this might take while)... "
  apt-get -qqy install quota quotatool > /dev/null 2>&1

  if ! [ -f /proc/user_beancounters ]; then

	  if [ `cat /etc/fstab | grep ',usrjquota=quota.user,grpjquota=quota.group,jqfmt=vfsv0' | wc -l` -eq 0 ]; then
		sed -i '/tmpfs/!s/errors=remount-ro/errors=remount-ro,usrjquota=aquota.user,grpjquota=aquota.group,jqfmt=vfsv0/' /etc/fstab
	  fi
	  if [ `cat /etc/fstab | grep 'defaults' | wc -l` -ne 0 ]; then
		sed -i '/tmpfs/!s/defaults/defaults,usrjquota=quota.user,grpjquota=quota.group,jqfmt=vfsv0/' /etc/fstab
	  fi
	  mount -o remount /
	  quotacheck -avugm > /dev/null 2>&1
	  quotaon -avug > /dev/null 2>&1

  fi
  echo -e "[${green}DONE${NC}]\n"
}
