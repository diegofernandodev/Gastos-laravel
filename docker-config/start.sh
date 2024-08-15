#!/bin/bash

# Iniciar PHP-FPM
php-fpm &

# Iniciar Nginx en primer plano
nginx -g 'daemon off;'
