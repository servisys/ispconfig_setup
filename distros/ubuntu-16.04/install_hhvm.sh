#---------------------------------------------------------------------
# Function: InstallHHVM
#    Install HHVM
#---------------------------------------------------------------------
InstallHHVM() {
  echo -n "Installing HHVM (Hip Hop Virtual Machine)... "
  # installs add-apt-repository
	apt_install software-properties-common
	apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0x5a16e7281be7a449
	add-apt-repository "deb http://dl.hhvm.com/ubuntu $(lsb_release -sc) main"
	hide_output apt-get update
	apt_install hhvm
 echo -e "[${green}DONE${NC}]\n"
}
