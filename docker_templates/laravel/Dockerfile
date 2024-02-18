FROM composer:2.5.0 as vendor

WORKDIR /app
COPY ./src/composer.json /app/composer.json
COPY ./src/composer.lock /app/composer.lock
RUN composer install --ignore-platform-reqs --no-interaction --no-plugins --no-scripts --prefer-dist

# Application
FROM public.ecr.aws/h1y8m9v5/nmsph-php8.2:latest
ENV HTTP_CONF <container_name>.conf

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

WORKDIR /app

# Etc
RUN echo "alias artisan='sudo -u www-data php artisan'" >> /root/.bashrc \
    && echo "alias composer='sudo -u www-data composer'" >> /root/.bashrc

# Supervisor    
COPY ./playbook/supervisord/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Apache
COPY ./playbook/httpd_conf/$HTTP_CONF /etc/apache2/sites-available/

# Redis
#COPY ./playbook/conf/redis/redis.conf /etc/redis/redis.conf

RUN a2enmod rewrite headers && service apache2 restart
RUN a2dissite 000-default.conf && a2ensite $HTTP_CONF

# Cron conf
COPY --chmod=644 ./playbook/cron/scheduler /etc/cron.d/scheduler
RUN crontab -u www-data /etc/cron.d/scheduler

# Deploy Site
COPY --chown=www-data:www-data ./src /app
COPY --from=vendor /app/vendor/ /app/vendor/

# Exposed Ports
EXPOSE 80 443

CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisor/conf.d/supervisord.conf"]