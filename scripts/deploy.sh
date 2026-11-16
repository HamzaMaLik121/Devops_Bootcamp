#!/usr/bin/env bash
set -euo pipefail
umask 002
cd /var/www/guestbook
composer install --no-dev --optimize-autoloader --no-interaction
php artisan migrate --force
php artisan config:cache
php artisan route:cache
php artisan view:cache
sudo -n chown -R ubuntu:www-data storage bootstrap/cache
sudo -n chmod -R ug+rwX storage bootstrap/cache
