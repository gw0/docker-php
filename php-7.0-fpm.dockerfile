FROM tozd/runit:ubuntu-xenial

# add cron
ENV MAILTO=

RUN apt-get update -qq \
 && apt-get install --no-install-recommends -y \
    cron

COPY ./etc/service/cron /etc/service/cron

# add mailer
ENV ADMINADDR=
ENV REMOTES=

VOLUME /var/log/nullmailer

RUN apt-get update -qq \
 && apt-get install --no-install-recommends -y \
    nullmailer \
 && mkdir -m 700 /var/spool/nullmailer.orig \
 && mv /var/spool/nullmailer/* /var/spool/nullmailer.orig/

COPY ./etc/service/nullmailer /etc/service/nullmailer

# add php
RUN apt-get update -qq \
 && apt-get install --no-install-recommends -y \
    php7.0-fpm \
    php7.0-opcache \
    php7.0-mysql \
    php7.0-pgsql \
    php7.0-gd \
    php7.0-mcrypt \
    php7.0-json \
 && for m in /etc/php/7.0/mods-available/*.ini; do phpenmod $(basename -s .ini "$m"); done \
 && { \
    echo '[global]'; \
    echo 'daemonize = no'; \
    echo 'error_log = /var/log/php-fpm/php_errors.log'; \

    echo; \
    echo '[www]'; \
    echo 'listen = [::]:80'; \
    echo ';clear_env = no'; \
    echo 'catch_workers_output = yes'; \
    echo 'access.log = /var/log/php-fpm/$pool.access.log'; \
    } | tee /etc/php/7.0/fpm/pool.d/zz-docker.conf

COPY ./etc/php/7.0 /etc/php/7.0
COPY ./etc/service/php-fpm /etc/service/php-fpm
