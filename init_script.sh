#!/bin/bash

if [ -f ".env" ]; then # scrip executed from repository root
    source .env
fi

echo "-- Ejecutando 'composer install'"
docker exec -i $APACHE_CONTAINER composer install --no-interaction --optimize-autoloader
echo "-- 'composer install' finalizado"

echo "-- Instalando framework toba"
docker exec -it $APACHE_CONTAINER bash -c "cd bin && export TOBA_INSTANCIA=desarrollo"
docker exec -it $APACHE_CONTAINER bash -c "cd bin && export TOBA_INSTALACION_DIR=/instalacion"
docker exec -it $APACHE_CONTAINER bash -c "cd bin && ./toba instalacion instalar"
echo "-- Framework toba instalado"

echo "-- Configurando permisos"
docker exec -it $APACHE_CONTAINER bash -c "chown -R $(whoami):www-data www temp instalacion vendor/siu-toba/framework/www vendor/siu-toba/framework/temp"
docker exec -it $APACHE_CONTAINER bash -c "chmod 775 -R www temp instalacion vendor/siu-toba/framework/www vendor/siu-toba/framework/temp"
echo "-- Permisos configurados"

echo "-- Levantando configuracion de sitio"
docker exec -it $APACHE_CONTAINER bash -c "ln -s instalacion/toba.conf /etc/apache2/sites-available/gestion.conf"
docker exec -it $APACHE_CONTAINER bash -c "a2ensite gestion.conf"
docker exec -it $APACHE_CONTAINER bash -c "service apache2 reload"
echo "-- Configuracion ok"
