#---------------------------------------------------------------------
# Function: InstallBasics
#    Install basic packages
#---------------------------------------------------------------------
InstallBasics() {
  echo -n "Updating yum package database and upgrading currently installed packages... "
  hide_output yum -y update 
  echo -e "[${green}DONE${NC}]\n"

  echo -n "Installing basic packages... "
  yum_install nano wget net-tools NetworkManager-tui selinux-policy deltarpm epel-release yum-priorities which
  rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY*
  sed -i "/mirrorlist=/ a priority=10" /etc/yum.repos.d/epel.repo
  echo -e "[${green}DONE${NC}]\n"
  
  echo -n "Disabling Firewall... "
  systemctl stop firewalld.service
  systemctl disable firewalld.service
  echo -e "[${green}DONE${NC}]\n"
  
  echo -n "Disabling SELinux... "
  sed -i "s/SELINUX=enforcing/SELINUX=disabled/" /etc/selinux/config
  echo -e "[${green}DONE${NC}]\n"
  
  echo -n "Installing Development Tools... "
  hide_output yum -y groupinstall 'Development Tools'  
  echo -e "[${green}DONE${NC}]\n"
}

