# FROM php:8.1.0-apache
# WORKDIR /var/www/html

# # Mod Rewrite
# RUN a2enmod rewrite

# # Linux Library
# RUN apt-get update -y && apt-get install -y \
#     libicu-dev \
#     libmariadb-dev \
#     unzip zip \
#     zlib1g-dev \
#     libpng-dev \
#     libjpeg-dev \
#     libfreetype6-dev \
#     libjpeg62-turbo-dev \
#     libpng-dev 

# # Composer
# COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# # PHP Extension
# RUN docker-php-ext-install gettext intl pdo_mysql gd

# RUN docker-php-ext-configure gd --enable-gd --with-freetype --with-jpeg \
#     && docker-php-ext-install -j$(nproc) gd

# # Establecer la imagen base de PHP con extensiones necesarias para Laravel
# FROM php:8.2-fpm

# # Instalar dependencias del sistema
# RUN apt-get update && apt-get install -y \
#     build-essential \
#     libpng-dev \
#     libjpeg62-turbo-dev \
#     libfreetype6-dev \
#     libonig-dev \
#     libzip-dev \
#     zip \
#     unzip \
#     git \
#     curl \
#     && docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd

# # Instalar Composer
# COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# # Establecer el directorio de trabajo
# WORKDIR /var/www

# # Copiar composer.json y composer.lock
# COPY composer.json composer.lock ./

# # Instalar dependencias de PHP
# RUN composer install --no-scripts --no-autoloader

# # # Copiar el archivo .env al contenedor
# # COPY .env .env

# # Copiar el resto de los archivos del proyecto
# COPY . .

# # Generar la caché de Composer
# RUN composer dump-autoload --optimize

# # Establecer permisos
# RUN chown -R www-data:www-data /var/www

# # Exponer el puerto en el que Laravel escucha
# EXPOSE 8000

# # Comando para iniciar el servidor PHP-FPM
# CMD ["php-fpm"]



# Establecer la imagen base de PHP con extensiones necesarias para Laravel
FROM php:8.2-fpm

# Instalar dependencias del sistema, incluyendo nano y otras utilidades
RUN apt-get update && apt-get install -y \
    build-essential \
    libpng-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    libonig-dev \
    libzip-dev \
    zip \
    unzip \
    git \
    curl \
    nano \
    vim \
    less \
    bash \
    nginx \
    && docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd

# Instalar Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Establecer el directorio de trabajo
WORKDIR /var/www

# Copiar composer.json y composer.lock
COPY composer.json composer.lock ./

# Instalar dependencias de PHP
RUN composer install --no-scripts --no-autoloader

# Copiar el archivo .env al contenedor
COPY .env .env

# Copiar el archivo www.conf configurado para escuchar en el puerto 8000
COPY ./docker-config/www.conf /usr/local/etc/php-fpm.d/www.conf

# Remover la configuración por defecto de Nginx si existe
RUN if [ -f /etc/nginx/conf.d/default.conf ]; then rm /etc/nginx/conf.d/default.conf; fi

# Copiar la configuración personalizada de Nginx
COPY nginx/nginx.conf /etc/nginx/conf.d/default.conf

# Copiar el resto de los archivos del proyecto
COPY . .

# Generar la caché de Composer
RUN composer dump-autoload --optimize

# Establecer permisos
RUN chown -R www-data:www-data /var/www

# Copiar el script de inicio
COPY ./docker-config/start.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh

# Exponer los puertos en los que PHP-FPM y Nginx escuchan
EXPOSE 80 8000

# Comando para iniciar Nginx y PHP-FPM
CMD ["/usr/local/bin/start.sh"]

