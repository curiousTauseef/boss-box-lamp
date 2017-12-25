#!/usr/bin/env bash

IP_ADDRESS=$1
SITE_NAME=$2
DATABASE_NAME=$3
MYSQL_PASSWORD=$4

if [ $MYSQL_PASSWORD != 'password' ];
then
    echo "Updating MySQL root password..."
    mysql -uroot -ppassword -e "SET PASSWORD FOR 'root'@'localhost' = PASSWORD('$MYSQL_PASSWORD'); FLUSH PRIVILEGES;"
fi

echo "Creating database, if it doesn't already exist..."
mysql -uroot -p$MYSQL_PASSWORD -e "CREATE DATABASE IF NOT EXISTS $DATABASE_NAME;"

PHP_INFO_FILE="/var/www/public/info.php"
if [ ! -f "$PHP_INFO_FILE" ]
then
    echo "Creating phpinfo file..."
    echo '<?php echo phpinfo(); ?>' > /var/www/public/info.php
fi

echo "Updating Apache ServerName..."
echo "ServerName $SITE_NAME" | sudo tee /etc/apache2/conf-available/servername.conf

echo "Setting xdebug IP address in PHP ini..."
echo "xdebug.remote_host=192.168.33.15" | sudo tee /etc/php/7.0/apache2/conf.d/user.ini

echo "Restarting web server..."
sudo service apache2 restart

echo "Setup complete."