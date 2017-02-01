#---------------------------------------------------------------------
# Function: InstallBasics
#    Install basic packages
#---------------------------------------------------------------------
InstallBasics() {
  echo -n "Updating currently installed packages... "
  yum -y update 
  echo -e "${green}done${NC}"

  echo -n "Installing basic packages... "
  yum -y install nano wget net-tools NetworkManager-tui
  echo -e "${green}done${NC}"
  
  echo -n "Disabling Firewall... "
  systemctl stop firewalld.service
  systemctl disable firewalld.service
  echo -e "${green}done${NC}"
  
  echo -n "Disabling SELinux... "
  sed -i "s/SELINUX=enforcing/SELINUX=disabled/" /etc/selinux/config
  echo -e "${green}done${NC}"
  
  echo -n "Enabling additional Repository..."
  rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY*
  rpm -ivh http://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-8.noarch.rpm
  yum -y install yum-priorities
  sed -i "s/mirrorlist=https:\\/\\/mirrors.fedoraproject.org\\/metalink?repo=epel-7\\&arch=\$basearch/mirrorlist=https:\\/\\/mirrors.fedoraproject.org\\/metalink?repo=epel-7\\&arch=\$basearch\\`echo \n`priority=10/" /etc/yum.repos.d/epel.repo
  yum update
  echo -e "${green}done${NC}"

  echo -n "Installing Development Tools..."
  yum -y groupinstall 'Development Tools'  
  echo -e "${green}done${NC}"
}

