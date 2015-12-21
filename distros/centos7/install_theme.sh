#!/bin/bash
InstallTheme() {
wget https://github.com/dclardy64/ISPConfig_Clean-3.0.5/archive/master.zip -P /tmp
unzip /tmp/master.zip
cp -R /tmp/ISPConfig_Clean-3.0.5-master/interface/* /usr/local/ispconfig/interface/

sed -i "s|\$conf\['theme'\] = 'default'|\$conf\['theme'\] = 'ispc-clean'|" /usr/local/ispconfig/interface/lib/config.inc.php
sed -i "s|\$conf\['logo'\] = 'themes/default|\$conf\['logo'\] = 'themes/ispc-clean|" /usr/local/ispconfig/interface/lib/config.inc.php

mysql -u root -p$CFG_MYSQL_ROOT_PWD < sql/ispc-clean.sql
}
