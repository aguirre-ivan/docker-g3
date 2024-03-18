#!/bin/bash

if [ -f ".env" ]; then
    source .env
fi

# echo "-- Clonando svn"
# svn checkout http://colab.siu.edu.ar/svn/guarani3/nodos/$SIGLAS_INSTITUCION/3w/trunk/$G_VERSION g3w3
# echo "-- svn clonado"

echo "-- Configurando permisos"
docker exec -it $APACHE_CONTAINER bash -c "cd ${GUARANI_AUTOGESTION_DIR} && chown -R www-data:www-data instalacion/log/ instalacion/cache/ instalacion/temp/ instalacion/operaciones_inactivas/ src/siu/www/js/escalas/ src/siu/www/temp/"
docker exec -it $APACHE_CONTAINER bash -c "cd ${GUARANI_AUTOGESTION_DIR} && chmod 775 -R instalacion/log/ instalacion/cache/ instalacion/temp/ instalacion/operaciones_inactivas/ src/siu/www/js/escalas/ src/siu/www/temp/"
echo "-- Permisos configurados"

echo "-- Levantando archivos de configuracion"
docker exec -it $APACHE_CONTAINER bash -c "cd ${GUARANI_AUTOGESTION_DIR}instalacion && cp alias_template.conf alias.conf"
docker exec -it $APACHE_CONTAINER bash -c "cd ${GUARANI_AUTOGESTION_DIR}instalacion && cp config_template.php config.php"
docker exec -it $APACHE_CONTAINER bash -c "cd ${GUARANI_AUTOGESTION_DIR}instalacion && cp login_template.php login.php"
echo "-- Archivos copiados"

echo "-- Ejecutando 'composer install'"
docker exec -it $APACHE_CONTAINER composer install --no-interaction --optimize-autoloader -d ${GUARANI_AUTOGESTION_DIR}
echo "-- 'composer install' finalizado"

echo "-- Copiando archivo config.php"
docker cp config/config.php ${APACHE_CONTAINER}:${GUARANI_AUTOGESTION_DIR}instalacion/config.php
echo "-- Archivo config.php copiado"

echo "-- Ejecutando 'composer install'"
docker exec -it $APACHE_CONTAINER composer install --no-interaction --optimize-autoloader -d ${GUARANI_AUTOGESTION_DIR}
echo "-- 'composer install' finalizado"

echo "-- Levantando sitio"
docker exec -it $APACHE_CONTAINER bash -c "a2ensite alias.conf"
docker exec -it $APACHE_CONTAINER bash -c "service apache2 reload"
echo "-- Sitio levantado"