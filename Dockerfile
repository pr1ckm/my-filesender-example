FROM php:8.2-apache

# System-Abhängigkeiten & PostgreSQL-Client installieren
RUN apt-get update && apt-get install -y \
    libpq-dev \
    libpng-dev \
    libzip-dev \
    libxml2-dev \
    libicu-dev \
    git \
    unzip \
    postgresql-client \
    && rm -rf /var/lib/apt/lists/*

# PHP-Erweiterungen installieren
RUN docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql \
    && docker-php-ext-install pdo pdo_pgsql pgsql gd zip xml intl bcmath

# PHP Fehleranzeige für saubere JS/JSON-Ausgaben deaktivieren
RUN echo "display_errors = Off" > /usr/local/etc/php/conf.d/error_reporting.ini \
    && echo "log_errors = On" >> /usr/local/etc/php/conf.d/error_reporting.ini

# Apache-Module aktivieren
RUN a2enmod rewrite headers

# Composer installieren
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Apache DocumentRoot auf /opt/filesender/www setzen
ENV APACHE_DOCUMENT_ROOT /opt/filesender/www
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/conf-available/*.conf

# Mod_rewrite Override für /opt/filesender/www aktivieren
RUN echo "<Directory /opt/filesender/www>\n\tOptions -Indexes +FollowSymLinks\n\tAllowOverride All\n\tRequire all granted\n</Directory>" >> /etc/apache2/apache2.conf

# FileSender v3.x Quellcode (master3 Branch) klonen
WORKDIR /opt/filesender
RUN git clone --depth 1 --branch master3 https://github.com/filesender/filesender.git .

# Composer-Abhängigkeiten installieren
RUN composer install --no-dev --optimize-autoloader

# Verzeichnisse für Uploads & Logs erstellen
RUN mkdir -p /opt/filesender/files /opt/filesender/log \
    && chown -R www-data:www-data /opt/filesender/files /opt/filesender/log

# Entrypoint-Skript kopieren
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["apache2-foreground"]