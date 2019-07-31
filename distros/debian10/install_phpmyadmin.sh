#---------------------------------------------------------------------
# Function: InstallphpMyAdmin
#    Install and configure phpMyAdmin
#---------------------------------------------------------------------
InstallphpmyAdmin() {
    phpMyAdmin = "4.9.0.1" #phpMyAdmin version 
    echo -n "Installing phpMyAdmin...."
    mkdir /usr/share/phpmyadmin
    mkdir /etc/phpmyadmin
    mkdir -p /var/lib/phpmyadmin/tmp
    chown -R www-data:www-data /var/lib/phpmyadmin
    touch /etc/phpmyadmin/htpasswd.setup
    cd /tmp
    wget https://files.phpmyadmin.net/phpMyAdmin/$phpMyAdmin/phpMyAdmin-$phpMyAdmin-all-languages.tar.gz
    tar xfz phpMyAdmin-$phpMyAdmin-all-languages.tar.gz
    mv phpMyAdmin-$phpMyAdmin-all-languages/* /usr/share/phpmyadmin/
    rm phpMyAdmin-$phpMyAdmin-all-languages.tar.gz
    rm -rf phpMyAdmin-$phpMyAdmin-all-languages
    cp /usr/share/phpmyadmin/config.sample.inc.php  /usr/share/phpmyadmin/config.inc.php
    sed -i "\$cfg['blowfish_secret'] = 'bD3e6wva9fnd93jVsb7SDgeiBCd452Dh'; \/* YOU MUST FILL IN THIS FOR COOKIE AUTH! *\/" /usr/share/phpmyadmin/config.inc.php
    sed -i "\$cfg['TempDir'] = '\/var\/lib\/phpmyadmin\/tmp';" /usr/share/phpmyadmin/config.inc.php
    echo -n "Creating Apache config file for PhpMyAmin"
    sed -i "# phpMyAdmin default Apache configuration " /etc/apache2/conf-available/phpmyadmin.conf
    sed -i "Alias \/phpmyadmin \/usr\/share\/phpmyadmin" /etc/apache2/conf-available/phpmyadmin.conf
    sed -i "<Directory \/usr\/share\/phpmyadmin>" /etc/apache2/conf-available/phpmyadmin.conf
    sed -i "Options FollowSymLinks" /etc/apache2/conf-available/phpmyadmin.conf
    sed -i "DirectoryIndex index.php" /etc/apache2/conf-available/phpmyadmin.conf
    sed -i "<IfModule mod_php7.c>" /etc/apache2/conf-available/phpmyadmin.conf
    sed -i "AddType application\/x-httpd-php .php" /etc/apache2/conf-available/phpmyadmin.conf
    sed -i "php_flag magic_quotes_gpc Off" /etc/apache2/conf-available/phpmyadmin.conf
    sed -i "php_flag track_vars On" /etc/apache2/conf-available/phpmyadmin.conf
    sed -i "php_flag register_globals Off" /etc/apache2/conf-available/phpmyadmin.conf
    sed -i "php_value include_path ." /etc/apache2/conf-available/phpmyadmin.conf
    sed -i "<\/IfModule>" /etc/apache2/conf-available/phpmyadmin.conf
    sed -i "<\/Directory>" /etc/apache2/conf-available/phpmyadmin.conf
    sed -i "# Authorize for setup" /etc/apache2/conf-available/phpmyadmin.conf
    sed -i "<Directory \/usr\/share\/phpmyadmin\/setup>" /etc/apache2/conf-available/phpmyadmin.conf
    sed -i "<IfModule mod_authn_file.c>" /etc/apache2/conf-available/phpmyadmin.conf
    sed -i "AuthType Basic" /etc/apache2/conf-available/phpmyadmin.conf
    sed -i 'AuthName "phpMyAdmin Setup" '/etc/apache2/conf-available/phpmyadmin.conf
    sed -i "AuthUserFile \/etc\/phpmyadmin\/htpasswd.setup" /etc/apache2/conf-available/phpmyadmin.conf
    sed -i "<\/IfModule>" /etc/apache2/conf-available/phpmyadmin.conf
    sed -i "Require valid-user" /etc/apache2/conf-available/phpmyadmin.conf
    sed -i "<\/Directory>" /etc/apache2/conf-available/phpmyadmin.conf
    sed -i "# Disallow web access to directories that don't need it" /etc/apache2/conf-available/phpmyadmin.conf
    sed -i "<Directory \/usr\/share\/phpmyadmin\/libraries>" /etc/apache2/conf-available/phpmyadmin.conf
    sed -i "Order Deny,Allow" /etc/apache2/conf-available/phpmyadmin.conf
    sed -i "Deny from All" /etc/apache2/conf-available/phpmyadmin.conf
    sed -i "<\/Directory>" /etc/apache2/conf-available/phpmyadmin.conf
    sed -i "<Directory \/usr\/share\/phpmyadmin\/setup\/lib>" /etc/apache2/conf-available/phpmyadmin.conf
    sed -i "Order Deny,Allow" /etc/apache2/conf-available/phpmyadmin.conf
    sed -i "Deny from All" /etc/apache2/conf-available/phpmyadmin.conf
    sed -i "<\/Directory>" /etc/apache2/conf-available/phpmyadmin.conf
    a2enconf phpmyadmin
    systemctl restart apache2
    echo -e "[${green}DONE${NC}]\n"
    echo -n "entering MariaDB shell..."
    mysql -u root -p
    mysql -e "CREATE DATABASE phpmyadmin;"
    mysql -e "CREATE USER 'pma'@'localhost' IDENTIFIED BY $CFG_MYSQL_ROOT_PWD;"
    mysql -e "GRANT ALL PRIVILEGES ON phpmyadmin.* TO 'pma'@'localhost' IDENTIFIED BY $CFG_MYSQL_ROOT_PWD WITH GRANT OPTION;"
    mysql -e "FLUSH PRIVILEGES;"
    mysql -e "EXIT;"
    mysql -u root -p phpmyadmin < /usr/share/phpmyadmin/sql/create_tables.sql
    sed -i "s/ \$cfg['Servers'][\$i]['controlhost']/\$cfg['Servers'][\$i]['controlhost'] = 'localhost';/" /usr/share/phpmyadmin/config.inc.php
    sed -i "s/ \$cfg['Servers'][\$i]['controlport']/\$cfg['Servers'][\$i]['controlport'] = '';/" /usr/share/phpmyadmin/config.inc.php
    sed -i "s/ \$cfg['Servers'][\$i]['controluser']/\$cfg['Servers'][\$i]['controluser'] = 'pma';/" /usr/share/phpmyadmin/config.inc.php
    sed -i "s/ \$cfg['Servers'][\$i]['controlpass']/\$cfg['Servers'][\$i]['controlpass'] = 'mypassword';/" /usr/share/phpmyadmin/config.inc.php
    sed -i "s/ \$cfg['Servers'][\$i]['pmadb']/\$cfg['Servers'][\$i]['pmadb'] = 'phpmyadmin';/" /usr/share/phpmyadmin/config.inc.php
    sed -i "s/ \$cfg['Servers'][\$i]['bookmarktable']/\$cfg['Servers'][\$i]['bookmarktable'] = 'pma__bookmark';/" /usr/share/phpmyadmin/config.inc.php
    sed -i "s/ \$cfg['Servers'][\$i]['relation']/\$cfg['Servers'][\$i]['relation'] = 'pma__relation';/" /usr/share/phpmyadmin/config.inc.php
    sed -i "s/ \$cfg['Servers'][\$i]['table_info']/\$cfg['Servers'][\$i]['table_info'] = 'pma__table_info';/" /usr/share/phpmyadmin/config.inc.php
    sed -i "s/ \$cfg['Servers'][\$i]['table_coords']/\$cfg['Servers'][\$i]['table_coords'] = 'pma__table_coords';/" /usr/share/phpmyadmin/config.inc.php
    sed -i "s/ \$cfg['Servers'][\$i]['pdf_pages']/\$cfg['Servers'][\$i]['pdf_pages'] = 'pma__pdf_pages';/" /usr/share/phpmyadmin/config.inc.php
    sed -i "s/ \$cfg['Servers'][\$i]['column_info']/\$cfg['Servers'][\$i]['column_info'] = 'pma__column_info';/" /usr/share/phpmyadmin/config.inc.php
    sed -i "s/ \$cfg['Servers'][\$i]['history']/\$cfg['Servers'][\$i]['history'] = 'pma__history';/" /usr/share/phpmyadmin/config.inc.php
    sed -i "s/ \$cfg['Servers'][\$i]['table_uiprefs']/\$cfg['Servers'][\$i]['table_uiprefs'] = 'pma__table_uiprefs';/" /usr/share/phpmyadmin/config.inc.php
    sed -i "s/ \$cfg['Servers'][\$i]['tracking']/\$cfg['Servers'][\$i]['tracking'] = 'pma__tracking';/" /usr/share/phpmyadmin/config.inc.php
    sed -i "s/ \$cfg['Servers'][\$i]['userconfig']/\$cfg['Servers'][\$i]['userconfig'] = 'pma__userconfig';/" /usr/share/phpmyadmin/config.inc.php
    sed -i "s/ \$cfg['Servers'][\$i]['recent']/\$cfg['Servers'][\$i]['recent'] = 'pma__recent';/" /usr/share/phpmyadmin/config.inc.php
    sed -i "s/ \$cfg['Servers'][\$i]['favorite']/\$cfg['Servers'][\$i]['favorite'] = 'pma__favorite';/" /usr/share/phpmyadmin/config.inc.php
    sed -i "s/ \$cfg['Servers'][\$i]['users']/\$cfg['Servers'][\$i]['users'] = 'pma__users';/" /usr/share/phpmyadmin/config.inc.php
    sed -i "s/ \$cfg['Servers'][\$i]['usergroups']/\$cfg['Servers'][\$i]['usergroups'] = 'pma__usergroups';/" /usr/share/phpmyadmin/config.inc.php
    sed -i "s/ \$cfg['Servers'][\$i]['navigationhiding']/\$cfg['Servers'][\$i]['navigationhiding'] = 'pma__navigationhiding';/" /usr/share/phpmyadmin/config.inc.php
    sed -i "s/ \$cfg['Servers'][\$i]['savedsearches']/\$cfg['Servers'][\$i]['savedsearches'] = 'pma__savedsearches';/" /usr/share/phpmyadmin/config.inc.php
    sed -i "s/ \$cfg['Servers'][\$i]['central_columns']/\$cfg['Servers'][\$i]['central_columns'] = 'pma__central_columns';/" /usr/share/phpmyadmin/config.inc.php
    sed -i "s/ \$cfg['Servers'][\$i]['designer_settings']/\$cfg['Servers'][\$i]['designer_settings'] = 'pma__designer_settings';/" /usr/share/phpmyadmin/config.inc.php
    sed -i "s/ \$cfg['Servers'][\$i]['export_templates']/\$cfg['Servers'][\$i]['export_templates'] = 'pma__export_templates';/" /usr/share/phpmyadmin/config.inc.php
    echo -e "[${green}DONE${NC}]\n"
}
