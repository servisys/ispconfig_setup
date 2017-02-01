#---------------------------------------------------------------------
# Function: InstallHHVM
#    Install HHVM
#---------------------------------------------------------------------
InstallHHVM() {
  echo -n "Installing HHVM...) "
  # installs add-apt-repository
	apt-get -yqq install software-properties-common
	apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0x5a16e7281be7a449
	add-apt-repository "deb http://dl.hhvm.com/ubuntu $(lsb_release -sc) main"
	apt-get update
	apt-get -yqq install hhvm
 echo -e "[${green}DONE${NC}]\n"
}
