#!/bin/bash
#Install apache httpd, php ad mariad server zip ad unzip
dnf install -y httpd wget php-mysqli php mariadb105-server zip unzip

#start and enable the htppd and mariadb server
systemctl start httpd mariadb
systemctl enable httpd mariadb

#download and install wordpress and extracts files, and moves them to the web root
cd var/www/html
wget https://wordpress.org/latest.zip
unzip latest.zip
mv wordpress/* .
mv wp-config-sample.php wp-config.php

#Configure WordPress Database Settings
#Replaces placeholders in wp-config.php with actual database details
sed -i 's/database_name_here/mydb/' wp-config.php
sed -i 's/username_here/wordpress/' wp-config.php
sed -i 's/password_here/1234567890/' wp-config.php

#Set Up MariaDB Database for WordPress
# Sets root password and creates WordPress database, user, and grants privileges

# Set root password
mysqladmin -u root password 1234567890

# Create database and user
mysql -u root -p1234567890 -e "CREATE DATABASE mydb;"
mysql -u root -p1234567890 -e "CREATE USER 'wordpress'@'%' IDENTIFIED BY '1234567890';"
mysql -u root -p1234567890 -e "GRANT ALL PRIVILEGES ON mydb.* TO 'wordpress'@'%';"
mysql -u root -p1234567890 -e "FLUSH PRIVILEGES;"
