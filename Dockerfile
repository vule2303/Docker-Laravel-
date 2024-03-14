# Use Ubuntu 22.04 as base image
FROM ubuntu:22.04

# Install software-properties-common and add the PHP PPA
RUN apt-get update && \
    apt-get install -y software-properties-common && \
    add-apt-repository ppa:ondrej/php && \
    apt-get update

# Install dependencies and Apache
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y apache2 \
    libapache2-mod-php8.2 \
    php8.2 \
    php8.2-mysql \
    php8.2-cli \
    php8.2-fpm \
    php8.2-common \
    php8.2-mysql \
    php8.2-zip \
    php8.2-gd \
    php8.2-mbstring \
    php8.2-curl \
    php8.2-xml \
    php8.2-bcmath \
    nano \
    curl \
    && a2enmod rewrite && a2enmod php8.2

# Copy virtual host config
COPY apache.conf /etc/apache2/sites-available/apache.conf

# Enable new site and disable default site
RUN a2ensite apache.conf \
    && a2dissite 000-default.conf
# Install specific version of MySQL
RUN apt-get install -y mysql-server

# Add your Laravel project source
COPY . /var/www/html/

# Set working directory to web root
WORKDIR /var/www/html/

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/composer

# Set an environment variable to allow Composer to run as super user, this is not the best practice and should be used cautiously.
ENV COMPOSER_ALLOW_SUPERUSER=1

# Install dependencies with Composer
RUN composer install --no-interaction

# Grant permissions for the Laravel app
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 775 /var/www/html/storage

# Expose port 80
EXPOSE 80

# Start Apache server
CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]

