FROM php:7.1-fpm-jessie

MAINTAINER "Dylan Miles" <dylan.g.miles@gmail.com>

# Install PHP-FPM and popular/moodle required extensions
RUN apt-get update && apt-get install -y \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libpng-dev \
        libxml2-dev \
        zlib1g-dev libicu-dev g++ \
        libmagickwand-dev \
        libc-client-dev libkrb5-dev \
        libmcrypt-dev \
        libmemcached-dev \
        libtidy-dev \
    #&& docker-php-ext-install -j$(nproc) pear \
    && docker-php-ext-install opcache \
    && docker-php-ext-install -j$(nproc) mysqli \        
    && docker-php-ext-configure imap --with-kerberos --with-imap-ssl \
    && docker-php-ext-install -j$(nproc) imap \     
    && docker-php-ext-install -j$(nproc) mcrypt \
    && pecl install memcached \
    && docker-php-ext-enable memcached \
    #&& docker-php-ext-install -j$(nproc) xcache \
    && docker-php-ext-install -j$(nproc) tidy \
    && docker-php-ext-install -j$(nproc) soap \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd \
    && docker-php-ext-install -j$(nproc) zip \
    && docker-php-ext-configure intl \
    && docker-php-ext-install -j$(nproc) intl \
    && docker-php-ext-install -j$(nproc) xmlrpc \
    && pecl install imagick \
    && docker-php-ext-enable imagick
    #&& docker-php-ext-install -j$(nproc) ldap \
    

# Upgrade pear
#RUN pear upgrade --force --alldeps http://pear.php.net/get/PEAR-1.10.1
#    #&& pear clear-cache \
#    #&& pear update-channels \
#    #&& pear upgrade \
#    #&& pear upgrade-all
#
## Install pear mail for some legacy applications
#RUN     pear install mail     \
#    &&  pear install Net_SMTP
#
##Patch pear mail to allow for certificate exceptions
#RUN sed -i "s/\$this->_socket_options = \$socket_options;/\$this->_socket_options = array('ssl' => array('verify_peer' => false, 'verify_peer_name' => false, 'allow_self_signed' => true));/" /usr/share/php/Net/SMTP.php
#

RUN cp /usr/local/etc/php/php.ini-production /usr/local/etc/php/php.ini


## Configure PHP-FPM
RUN sed -i "s/;date.timezone =.*/date.timezone = UTC/" /usr/local/etc/php/php.ini && \
    sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /usr/local/etc/php/php.ini && \
    sed -i "s/display_errors = Off/display_errors = stderr/" /usr/local/etc/php/php.ini && \
    sed -i "s/upload_max_filesize = 2M/upload_max_filesize = 30M/" /usr/local/etc/php/php.ini && \
    sed -i "s/post_max_size = 8M/post_max_size = 30M/" /usr/local/etc/php/php.ini && \
    sed -i "s/;opcache.enable=0/opcache.enable=1/" /usr/local/etc/php/php.ini && \
    sed -i "s/;opcache.memory_consumption=64/opcache.memory_consumption=128/" /usr/local/etc/php/php.ini && \
    sed -i "s/;opcache.max_accelerated_files=2000/opcache.max_accelerated_files=8000/" /usr/local/etc/php/php.ini && \
    sed -i "s/;opcache.revalidate_freq=2/opcache.revalidate_freq=60/" /usr/local/etc/php/php.ini && \
    sed -i "s/;opcache.use_cwd=1/opcache.use_cwd=1/" /usr/local/etc/php/php.ini && \
    sed -i "s/;opcache.validate_timestamps=1/opcache.validate_timestamps=1/" /usr/local/etc/php/php.ini && \
    sed -i "s/;opcache.save_comments=1/opcache.save_comments=1/" /usr/local/etc/php/php.ini && \
    sed -i "s/;opcache.enable_file_override=0/opcache.enable_file_override=0/" /usr/local/etc/php/php.ini && \
    sed -i "s/max_execution_time = 30/max_execution_time = 300/" /usr/local/etc/php/php.ini && \
    sed -i -e "s/;daemonize\s*=\s*yes/daemonize = no/g" /usr/local/etc/php-fpm.conf && \
    sed -i '/^listen = /clisten = 9000' /usr/local/etc/php-fpm.d/www.conf && \
    sed -i '/^listen.allowed_clients/c;listen.allowed_clients =' /usr/local/etc/php-fpm.d/www.conf && \
    sed -i '/^;catch_workers_output/ccatch_workers_output = yes' /usr/local/etc/php-fpm.d/www.conf && \
    sed -i '/^;env\[TEMP\] = .*/aenv[DB_PORT_3306_TCP_ADDR] = $DB_PORT_3306_TCP_ADDR' /usr/local/etc/php-fpm.d/www.conf

RUN mkdir -p /data
VOLUME ["/data"]

EXPOSE 9000

ENTRYPOINT ["/usr/local/sbin/php-fpm", "-F"]

