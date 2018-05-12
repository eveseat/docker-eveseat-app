#!/bin/sh
set -e

cd /var/www/seat

chown -R www-data:www-data storage

# Wait for the database
while ! mysqladmin ping -hmariadb --silent; do

    echo "MariaDB container might not be ready yet... sleeping..."
    sleep 10
done

# Check if we have to start first-run routines...
if [ ! -f /root/.seat-installed ]; then

    echo "Starting first-run routines..."

    # Create an .env if needed
    php -r "file_exists('.env') || copy('.env.example', '.env');"

    # Generate the applications key
    php artisan key:generate

    # Run any migrations
    php artisan migrate

    # Update the SDE
    php artisan eve:update:sde -n

    # Run the schedule seeder
    php artisan db:seed --class=Seat\\Services\\database\\seeds\\ScheduleSeeder

    # Mark this environment as installed
    touch /root/.seat-installed

    echo "Completed first run routines..."
fi

php-fpm -F
