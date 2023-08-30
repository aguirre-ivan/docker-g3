#!/bin/bash

if [ -f ".env" ]; then # scrip executed from repository root
    source .env
fi

echo "-- Clonando svn"
svn checkout https://colab.siu.edu.ar/svn/guarani3/nodos/$SIGLAS_INSTITUCION/gestion/trunk/$G_VERSION guarani
echo "-- svn clonado"

echo "-- Levantando contenedores"
docker compose up -d
echo "-- Contenedores ok"

echo "-- Ejecutando 'composer install'"
docker exec -i $APACHE_CONTAINER composer install --no-interaction --optimize-autoloader
echo "-- 'composer install' finalizado"

echo "-- Instalando framework toba"
docker exec -it $APACHE_CONTAINER bash -c "cd bin && export TOBA_INSTANCIA=desarrollo"
docker exec -it $APACHE_CONTAINER bash -c "cd bin && export TOBA_INSTALACION_DIR=/instalacion"
docker exec -it $APACHE_CONTAINER bash -c "cd bin && ./toba instalacion instalar"
echo "-- Framework toba instalado"

echo "-- Configurando permisos"
docker exec -it $APACHE_CONTAINER bash -c "chown -R www-data:www-data www temp instalacion vendor/siu-toba/framework/www vendor/siu-toba/framework/temp /etc/apache2/sites-available/toba_3_3.conf"
docker exec -it $APACHE_CONTAINER bash -c "chmod 775 -R www temp instalacion vendor/siu-toba/framework/www vendor/siu-toba/framework/temp"
echo "-- Permisos configurados"

echo "-- Levantando configuracion de sitio"
docker exec -it $APACHE_CONTAINER bash -c "a2dissite default.conf"
docker exec -it $APACHE_CONTAINER bash -c "service apache2 reload"
docker exec -it $APACHE_CONTAINER bash -c "a2ensite toba_3_3.conf"
docker exec -it $APACHE_CONTAINER bash -c "service apache2 reload"
echo "-- Configuracion ok"

echo "-- Agregar los parámetros de localización de fop"
docker exec -it $APACHE_CONTAINER bash -c "echo '
[xslfo]
fop=/usr/local/proyectos/guarani/php/3ros/fop/fop
' >> instalacion/instalacion.ini"
echo "-- Parametros agregados"

echo "--"
docker exec -it $APACHE_CONTAINER bash -c "cp menu.ini.tmpl menu.ini"
docker exec -it $APACHE_CONTAINER bash -c "cd bin && ./guarani cargar -d /usr/local/proyectos/guarani/"
docker exec -it $APACHE_CONTAINER bash -c "service apache2 reload"
echo "--"

echo "-- Configurando permisos"
docker exec -it $APACHE_CONTAINER bash -c "chown -R www-data:www-data www temp instalacion vendor/siu-toba/framework/www vendor/siu-toba/framework/temp /etc/apache2/sites-available/toba_3_3.conf"
docker exec -it $APACHE_CONTAINER bash -c "chmod 775 -R www temp instalacion vendor/siu-toba/framework/www vendor/siu-toba/framework/temp"
echo "-- Permisos configurados"

echo "-- Instalando guarani"
docker exec -it $APACHE_CONTAINER bash -c "cd bin && ./guarani instalar"
echo "-- Guarani instalado"

# docker exec -it $APACHE_CONTAINER bash -c "echo '
# [desarrollo guarani guarani]
# motor = "postgres7"
# profile = "postgres"
# usuario = "postgres"
# clave = "123456"
# base = "toba_3_3"
# puerto = "5432"
# encoding = "LATIN1"
# schema = "negocio"
# ' >> instalacion/bases.ini"