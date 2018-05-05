FROM php:7.1-fpm-alpine

# Install OS level dependencies
RUN apk add --no-cache git zip unzip curl \
    libpng-dev libmcrypt-dev bzip2-dev icu-dev mariadb-client && \
    docker-php-ext-install pdo_mysql gd bz2 intl mcrypt pcntl && \
    # Prepare composer for use
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin \
    --filename=composer && hash -r && \
    # Prepare the /var/www directory for SeAT
    cd /var/www && \
    composer create-project eveseat/seat --stability beta --no-dev --no-ansi --no-progress && \
    # Publish assets and migrations
    cd /var/www/seat && \
    php artisan vendor:publish --force --all && \
    php artisan l5-swagger:generate

COPY startup.sh /root/startup.sh
RUN chmod +x /root/startup.sh

CMD ["php-fpm", "-F"]

ENTRYPOINT ["/bin/sh", "/root/startup.sh"]
