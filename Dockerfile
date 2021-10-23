# **************************************************************************** #
#                                                                              #
#                                                         ::::::::             #
#    Dockerfile                                         :+:    :+:             #
#                                                      +:+                     #
#    By: smiller <smiller@student.codam.nl>           +#+                      #
#                                                    +#+                       #
#    Created: 2020/11/28 13:28:20 by smiller       #+#    #+#                  #
#    Updated: 2020/11/29 14:10:12 by smiller       ########   odam.nl          #
#                                                                              #
# **************************************************************************** #

# OS
FROM	debian:buster

# AUTHOR METADATA
LABEL	maintainer="smiller@student.codam.nl"

# PORT METADATA
EXPOSE	80 443

# AUTOINDEX
COPY    srcs/autoindex.sh /.
RUN     chmod 775 autoindex.sh

# INSTALLS / UPDATES
RUN	apt update; \
	apt upgrade -y; \
        apt -y install php-fpm php-mysql php-mbstring; \
	apt -y install wget; \
	apt -y install nginx; \
        apt -y install mariadb-server; \
        apt -y install sendmail; \
        sendmailconfig

#  SSL
RUN     openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout /etc/ssl/private/nginx_selfsigned.key \
        -out /etc/ssl/certs/nginx_selfsigned.crt \
        -subj "/C=NL/ST=NH/L=Amsterdam/O=Codam/CN=www_localhost_com"; \
        chmod 775 /etc/ssl/private/nginx_selfsigned.key; \
        chmod 775 /etc/ssl/certs/nginx_selfsigned.crt

# COPY NGINX CONFIG FILE TO NGINX AND SYMLINK to sites-enabled
COPY	srcs/nginx.conf /etc/nginx/sites-available/localhost
RUN	ln -s /etc/nginx/sites-available/localhost /etc/nginx/sites-enabled/localhost

# PHPMYADMIN
RUN     wget -P var/www/html/ https://files.phpmyadmin.net/phpMyAdmin/4.9.7/phpMyAdmin-4.9.7-all-languages.tar.gz; \
        tar -xvf var/www/html/phpMyAdmin-4.9.7-all-languages.tar.gz -C var/www/html; \
        mv var/www/html/phpMyAdmin-4.9.7-all-languages var/www/html/phpmyadmin; \
        rm -f phpMyAdmin-4.9.7-all-languages.tar.gz

# COPY PHP CONFIG FILE TO NGINX AND UPDATE PERMISSIONS
COPY    srcs/config.inc.php var/www/html/phpmyadmin/config.inc.php
RUN     chmod 660 /var/www/html/phpmyadmin/config.inc.php

# MYSQL
RUN     service mysql start; \
        mysql < /var/www/html/phpmyadmin/sql/create_tables.sql; \
        mysql -u root; \
        mysql -e "CREATE DATABASE wordpress_db;"; \
        mysql -e "GRANT ALL PRIVILEGES ON *.* TO 'phpmyadmin_user'@'localhost' \
        IDENTIFIED BY 'password' WITH GRANT OPTION;"; \
        mysql -e "FLUSH PRIVILEGES;"

# WORDPRESS
RUN     service mysql start; \
        wget -P var/www/html/ https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar; \
        chmod 755 var/www/html/wp-cli.phar; \
        mv var/www/html/wp-cli.phar /usr/local/bin/wp; \
        cd var/www/html/; \
        wp core download --allow-root; \
        wp config create \
        --dbname=wordpress_db \
        --dbuser=phpmyadmin_user \
        --dbpass=password \
        --allow-root; \
        wp core install \
        --url=localhost.com \
        --title=ft_server \
        --admin_user=wp_user \
        --admin_password=password \
        --admin_email=smiller@student.codam.nl \
        --allow-root; \
	mysql -e "USE wordpress_db; UPDATE wp_options SET option_value='https://localhost/' \
        WHERE option_name='siteurl' OR option_name='home';"

# CHANGE MAX UPLOAD FILE SIZE
RUN     sed -i 's/upload_max_filesize = 2M/ upload_max_filesize = 20M/' /etc/php/7.3/fpm/php.ini; \
        sed -i 's/post_max_size = 8M/ post_max_size = 21M/' /etc/php/7.3/fpm/php.ini

# CHANGE PERMISSIONS FOR ALL DIRECTORIES
RUN     chown -R www-data:www-data /var/www/html

# SET DEFAULT COMMANDS FOR CONTAINER
CMD	service nginx start; \
        service mysql start; \
        service php7.3-fpm start; \
        service sendmail start; \
        bash; \
        tail -f /var/log/nginx/access.log
