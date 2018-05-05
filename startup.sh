#!/bin/sh
set -e

cd /var/www/seat

# Ensure the logs directory is writable
chown -R www-data:www-data storage

# Wait for the database
while ! mysqladmin ping -hmariadb --silent; do

    echo "MariaDB container might not be ready yet... sleeping..."
    sleep 3
done

# Run any migrations
php artisan migrate

# Regenerate API documentation
php artisan l5-swagger:generate

# Download the SDE
#php artisan eve:update-sde -n

php-fpm -F
