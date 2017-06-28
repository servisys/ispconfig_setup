InstallFix(){
  MYNET=`cat /etc/postfix/main.cf | grep "mynetworks =" | sed 's/mynetworks = //'`
  echo "@mynetworks = qw( $MYNET );" >> /etc/amavis/conf.d/20-debian_defaults
  if [ -f /etc/init.d/amavisd-new ]; then
	service amavisd-new restart > /dev/null 2>&1
  else
	service amavis restart > /dev/null 2>&1
  fi
  
  if [ $CFG_WEBMAIL == "roundcube" ]; then
	mysql -uroot -p$CFG_MYSQL_ROOT_PWD dbispconfig -e "INSERT INTO remote_user (remote_userid, sys_userid, sys_groupid, sys_perm_user, sys_perm_group, sys_perm_other, remote_username, remote_password, remote_functions) VALUES (1, 1, 1, 'riud', 'riud', '', 'roundcube', MD5('$CFG_ROUNDCUBE_PWD'), 'server_get,get_function_list,client_templates_get_all,server_get_serverid_by_ip,server_ip_get,server_ip_add,server_ip_update,server_ip_delete;client_get_all,client_get,client_add,client_update,client_delete,client_get_sites_by_user,client_get_by_username,client_change_password,client_get_id,client_delete_everything;mail_user_get,mail_user_add,mail_user_update,mail_user_delete;mail_alias_get,mail_alias_add,mail_alias_update,mail_alias_delete;mail_spamfilter_user_get,mail_spamfilter_user_add,mail_spamfilter_user_update,mail_spamfilter_user_delete;mail_policy_get,mail_policy_add,mail_policy_update,mail_policy_delete;mail_fetchmail_get,mail_fetchmail_add,mail_fetchmail_update,mail_fetchmail_delete;mail_spamfilter_whitelist_get,mail_spamfilter_whitelist_add,mail_spamfilter_whitelist_update,mail_spamfilter_whitelist_delete;mail_spamfilter_blacklist_get,mail_spamfilter_blacklist_add,mail_spamfilter_blacklist_update,mail_spamfilter_blacklist_delete;mail_user_filter_get,mail_user_filter_add,mail_user_filter_update,mail_user_filter_delete');"
	ln -s /usr/local/ispconfig/interface/ssl/ispserver.crt /usr/local/share/ca-certificates/ispserver.crt
	update-ca-certificates > /dev/null 2>&1
	sed -i 's/;openssl.cafile=/openssl.cafile=\/etc\/ssl\/certs\/ca-certificates.crt/' /etc/php/7.0/apache2/php.ini
	sed -i 's/;openssl.cafile=/openssl.cafile=\/etc\/ssl\/certs\/ca-certificates.crt/' /etc/php/7.0/fpm/php.ini
	if [ $CFG_WEBSERVER == "apache" ]; then
		service apache2 reload > /dev/null 2>&1
		service php7-fpm reload > /dev/null 2>&1
	else
		service nginx reload > /dev/null 2>&1
		service php7-fpm reload > /dev/null 2>&1
	fi
  fi
}
