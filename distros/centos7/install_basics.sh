#---------------------------------------------------------------------
# Function: InstallBasics
#    Install basic packages
#---------------------------------------------------------------------
InstallBasics() {
  echo -n "Updating apt and upgrading currently installed packages... "
  yum -y update 
  echo -e "${green}done${NC}"

  echo -n "Installing basic packages... "
  yum -y install nano
  echo -e "${green}done${NC}"
}

