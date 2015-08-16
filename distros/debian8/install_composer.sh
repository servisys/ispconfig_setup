#---------------------------------------------------------------------
# Function: InstallComposer
#    Install php composer especially for roundcube
#---------------------------------------------------------------------
InstallComposer() {
  # Test if Composer is installed
  composer -v > /dev/null 2>&1
  COMPOSER_IS_INSTALLED=$?
  
  # True, if composer is not installed
  if [[ $COMPOSER_IS_INSTALLED -ne 0 ]]; then
      echo "Installing Composer..."
          # Install Composer
          curl -sS https://getcomposer.org/installer | php
          mv composer.phar /usr/local/bin/composer
      fi
  else
      echo "Updating Composer..."

      composer self-update
  fi
}

