FROM dylangmiles/docker-moodle-phpfpm:php-7.3

MAINTAINER "Dylan Miles" <dylan.g.miles@gmail.com>


# Install PHP-FPM and popular/moodle required extensions
RUN docker-php-ext-install -j$(nproc) xdebug
    

 #DEBUG ONLY: Configure XDebug
RUN   echo "xdebug.remote_enable = 1" >> /etc/php5/fpm/conf.d/20-xdebug.ini
RUN   echo "xdebug.remote_port = 9000" >> /etc/php5/fpm/conf.d/20-xdebug.ini
RUN   echo "xdebug.remote_host=debughost" >> /etc/php5/fpm/conf.d/20-xdebug.ini
RUN   echo "xdebug.remote_autostart=1" >> /etc/php5/fpm/conf.d/20-xdebug.ini

#DEBUG ONLY: Allow environment variables to be picked up in $_SERVER by php-fpm for debugging purposes (eg. $PHP_IDE_CONFIG)
RUN sed -i "s/;clear_env.*=.*/clear_env = no/" /etc/php5/fpm/pool.d/www.conf

