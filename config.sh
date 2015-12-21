#!/bin/bash

genpasswd() {
    count=0
    while [ $count -lt 3 ]
    do
        pw_valid=$(tr -cd A-Za-z0-9 < /dev/urandom | fold -w24 | head -n1)
        count=$(grep -o "[0-9]" <<< $pw_valid | wc -l)
    done
    echo $pw_valid
}

CFG_SQLSERVER="MySQL"
CFG_MYSQL_ROOT_PWD=`genpasswd`
CFG_PMA_PWD=`genpasswd`
CFG_WEBSERVER="apache"
CFG_XCACHE="no"
CFG_PHPMYADMIN="yes"
CFG_MTA="dovecot"
CFG_AVUPDATE="yes"
CFG_QUOTA="n"
CFG_ISPC="standard"
CFG_JKIT="n"
CFG_DKIM="y"
SSL_COUNTRY="FR"
SSL_STATE="Paris"
SSL_LOCALITY="Paris"
SSL_ORGANIZATION=$CFG_HOSTNAME_FQDN
SSL_ORGUNIT="ISPConfig"
CFG_ISPCONFIG_PWD=`genpasswd`

rm /root/.my.cnf
echo "
[client]
host     = localhost
user     = root
password=$CFG_MYSQL_ROOT_PWD
" > /root/.my.cnf