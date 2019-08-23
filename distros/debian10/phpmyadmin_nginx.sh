#---------------------------------------------------------------------
# Function: Confi_phpMyAdmin_nginx
#    Configure phpMyAdmin for nginx
#---------------------------------------------------------------------
config_phpMyAdmin_nginx() {
    touch /etc/nginx/conf.d/phpMyAdmin.conf
    cat /etc/nginx/conf.d/phpMyAdmin.conf <<EOF

## phpMyAdmin default nginx configuration

server {
   listen 80;
   server_name "";
   root /usr/share/phpMyAdmin;

   location /phpmyadmin {
               root /usr/share/;
               index index.php index.html index.htm;
               location ~ ^/phpmyadmin/(.+\.php)$ {
                       try_files $uri =404;
                       root /usr/share/;
                       fastcgi_pass unix:/var/run/php/php7.0-fpm.sock;
                       fast_cgi_param HTTPS $https;
                       fastcgi_index index.php;
                       fastcgi_param SCRIPT_FILENAME $request_filename;
                       include /etc/nginx/fastcgi_params;
                       fastcgi_param PATH_INFO $fastcgi_script_name;
                       fastcgi_buffer_size 128k;
                       fastcgi_buffers 256 4k;
                       fastcgi_busy_buffers_size 256k;
                       fastcgi_temp_file_write_size 256k;
                       fastcgi_intercept_errors on;
               }
               ## Images and static content is treated different
               location ~* ^/phpmyadmin/(.+\.(jpg|jpeg|gif|css|png|js|ico|html|xml|txt))$ {
                       root /usr/share/;
               }
        }
        location /phpMyAdmin {
               rewrite ^/* /phpmyadmin last;
        }
   location / {
      index index.php;
   }

## Images and static content is treated different
   location ~* ^.+.(jpg|jpeg|gif|css|png|js|ico|xml)$ {
      access_log off;
      expires 30d;
   }

   location ~ /\.ht {
      deny all;
   }

   location ~ /(libraries|setup/frames|setup/libs) {
      deny all;
      return 404;
   }

   location ~ \.php$ {
      include /etc/nginx/fastcgi_params;
      fastcgi_pass 127.0.0.1:9000;
      fastcgi_index index.php;
      fastcgi_param SCRIPT_FILENAME /usr/share/phpMyAdmin$fastcgi_script_name;
   }
}

EOF
    a2enconf phpmyadmin > /dev/null 2>&1
    systemctl reload nginx
}
