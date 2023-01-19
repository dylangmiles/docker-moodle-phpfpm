FROM php:8.0.27-fpm-bullseye

MAINTAINER "Dylan Miles" <dylan.g.miles@gmail.com>

ADD scripts/ /scripts
# Fix the original permissions of /tmp, the PHP default upload tmp dir.
RUN chmod 777 /scripts && chmod +t /scripts

# Setup the required extensions.
ARG DEBIAN_FRONTEND=noninteractive
RUN /scripts/php-extensions.sh

RUN cp /usr/local/etc/php/php.ini-production /usr/local/etc/php/php.ini

## Configure PHP-FPM
RUN sed -i "s/;date.timezone =.*/date.timezone = UTC/" /usr/local/etc/php/php.ini && \
    sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /usr/local/etc/php/php.ini && \
    sed -i "s/display_errors = Off/display_errors = stderr/" /usr/local/etc/php/php.ini && \
    sed -i "s/upload_max_filesize = 2M/upload_max_filesize = 100M/" /usr/local/etc/php/php.ini && \
    sed -i "s/post_max_size = 8M/post_max_size = 100M/" /usr/local/etc/php/php.ini && \
    sed -i "s/;opcache.enable=0/opcache.enable=1/" /usr/local/etc/php/php.ini && \
    sed -i "s/;opcache.memory_consumption=64/opcache.memory_consumption=128/" /usr/local/etc/php/php.ini && \
    sed -i "s/;opcache.max_accelerated_files=2000/opcache.max_accelerated_files=8000/" /usr/local/etc/php/php.ini && \
    sed -i "s/;opcache.revalidate_freq=2/opcache.revalidate_freq=60/" /usr/local/etc/php/php.ini && \
    sed -i "s/;opcache.use_cwd=1/opcache.use_cwd=1/" /usr/local/etc/php/php.ini && \
    sed -i "s/;opcache.validate_timestamps=1/opcache.validate_timestamps=1/" /usr/local/etc/php/php.ini && \
    sed -i "s/;opcache.save_comments=1/opcache.save_comments=1/" /usr/local/etc/php/php.ini && \
    sed -i "s/;opcache.enable_file_override=0/opcache.enable_file_override=0/" /usr/local/etc/php/php.ini && \
    sed -i "s/;max_input_vars = 1000/max_input_vars = 5000/" /usr/local/etc/php/php.ini && \
    sed -i "s/max_execution_time = 30/max_execution_time = 300/" /usr/local/etc/php/php.ini && \
    sed -i -e "s/;daemonize\s*=\s*yes/daemonize = no/g" /usr/local/etc/php-fpm.conf && \
    sed -i '/^listen = /clisten = 9000' /usr/local/etc/php-fpm.d/www.conf && \
    sed -i '/^listen.allowed_clients/c;listen.allowed_clients =' /usr/local/etc/php-fpm.d/www.conf && \
    sed -i '/^;catch_workers_output/ccatch_workers_output = yes' /usr/local/etc/php-fpm.d/www.conf && \
    sed -i '/^;env\[TEMP\] = .*/aenv[DB_PORT_3306_TCP_ADDR] = $DB_PORT_3306_TCP_ADDR' /usr/local/etc/php-fpm.d/www.conf


RUN mkdir -p /data
VOLUME ["/data"]

EXPOSE 9000

#ENTRYPOINT ["cat", "/usr/local/etc/php/php.ini"]
#ENTRYPOINT ["/usr/local/bin/php", "-i"]


ENTRYPOINT ["/usr/local/sbin/php-fpm", "-F"]
