FROM php:8.1.0-fpm

ARG AMBIENTE=${AMBIENTE} \
    USER=${USER} \
    CUSTOMUID=${CUSTOMUID} \
    CUSTOMGID=${CUSTOMGID} \
    APACHE= ${APACHE}

#COMANDOS PARA SETEAR EL PROPIETARIO DEL DIRECTORIO
RUN echo "USUARIO: ${USER}"    
RUN echo "CUSTOMUID: ${CUSTOMUID}"    
RUN echo "CUSTOMGID: ${CUSTOMGID}"
RUN echo "APACHE: ${APACHE}"
RUN groupadd -g $CUSTOMGID -o $USER
RUN useradd -u $CUSTOMUID $USER -g ${APACHE} -o -m
# USAR CONFIGURACION PHP DE PRODUCCION
COPY ./deploy/php/php.ini "$PHP_INI_DIR/php.ini"
COPY ./deploy/env-example ../.env

#INSTALAR LIBRERIAS UBUNTU
RUN apt-get update && apt-get install -y apt-utils iputils-ping telnet vim git libxml2-dev libpng-dev libzip-dev 

#AGREGAR REPOSITORIO NODE Y NPM 16 INSTALAR
RUN curl -sL https://deb.nodesource.com/setup_16.x  | bash - 
RUN apt-get install -y nodejs    

#INSTALAR LIBRERIAS PHP
RUN docker-php-ext-install soap gd ctype bcmath zip

#INSTALAR POSTGRES PHP
RUN apt-get install -y libpq-dev \
    && docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql \
    && docker-php-ext-install pdo pdo_pgsql pgsql

#INSTALAR COMPOSER GLOBALMENTE COPIAR EL CODIGO Y SETEA EL DIRECTORIO DE TRABAJO
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
#COMANDOS PROPIOS PARA EL MADSIS
COPY --chown=$USER:$APACHE ./ /var/www
WORKDIR /var/www
RUN chown -R $USER:$APACHE .
USER $USER
RUN composer install
RUN php artisan storage:link
#RUN npm install
#RUN npm run prod
#INICIA EL SERVICIO PHP-FPM
USER root
CMD ["php-fpm"]
EXPOSE 9000