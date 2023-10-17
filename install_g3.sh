#!/bin/bash

if [ -f ".env" ]; then
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

DUMP_DIR="$PWD/init"
FILE_DUMP=$(ls -1 "$DUMP_DIR" | head -n 1)

echo "-- Cargando dump de base (si existe)"
if [ -n "$FILE_DUMP" ]; then
    FILE_DUMP="$DUMP_DIR/$FILE_DUMP"
    echo "-- Cargando el primer archivo de dump: $FILE_DUMP"
    docker exec -i $POSTGRES_CONTAINER dropdb -U $POSTGRES_USER -h localhost -p 5432 $POSTGRES_DB
    docker exec -i $POSTGRES_CONTAINER createdb -U $POSTGRES_USER -h localhost -p 5432 $POSTGRES_DB

    docker exec -i $POSTGRES_CONTAINER psql -d $POSTGRES_DB -U $POSTGRES_USER < "$FILE_DUMP"
    echo "-- Dump cargado"
else
    echo "-- No se encontraron archivos de dump en $DUMP_DIR. No se realizó la carga."
fi

echo "-- Instalando framework toba"
docker exec -it $APACHE_CONTAINER bash -c "cd bin && export TOBA_INSTANCIA=desarrollo"
docker exec -it $APACHE_CONTAINER bash -c "cd bin && export TOBA_INSTALACION_DIR=${GUARANI_INSTALATION_DIR}
instalacion"
docker exec -it $APACHE_CONTAINER bash -c "cd bin && ./toba instalacion instalar"
echo "-- Framework toba instalado"

echo "-- Configurando permisos"
docker exec -it $APACHE_CONTAINER bash -c "chown -R www-data:www-data www temp instalacion vendor/siu-toba/framework/www vendor/siu-toba/framework/temp /etc/apache2/sites-available/toba_3_3.conf"
docker exec -it $APACHE_CONTAINER bash -c "chmod 775 -R www temp instalacion vendor/siu-toba/framework/www vendor/siu-toba/framework/temp"
echo "-- Permisos configurados"

echo "-- Levantando configuracion de sitio"
docker exec -it $APACHE_CONTAINER bash -c "a2dissite 000-default.conf"
docker exec -it $APACHE_CONTAINER bash -c "service apache2 reload"
docker exec -it $APACHE_CONTAINER bash -c "a2ensite toba_3_3.conf"
docker exec -it $APACHE_CONTAINER bash -c "service apache2 reload"  
echo "-- Configuracion ok"

echo "-- Agregar los parámetros de localización de fop"
docker exec -it $APACHE_CONTAINER bash -c "echo '
[xslfo]
fop=${GUARANI_INSTALATION_DIR}php/3ros/fop/fop
' >> instalacion/instalacion.ini"
echo "-- Parametros agregados"

echo "--"
docker exec -it $APACHE_CONTAINER bash -c "cp menu.ini.tmpl menu.ini"
docker exec -it $APACHE_CONTAINER bash -c "cd bin && ./guarani cargar -d ${GUARANI_INSTALATION_DIR}"
docker exec -it $APACHE_CONTAINER bash -c "service apache2 reload"
echo "--"

echo "-- Configurando permisos"
docker exec -it $APACHE_CONTAINER bash -c "chown -R www-data:www-data www temp instalacion vendor/siu-toba/framework/www vendor/siu-toba/framework/temp /etc/apache2/sites-available/toba_3_3.conf"
docker exec -it $APACHE_CONTAINER bash -c "chmod 775 -R www temp instalacion vendor/siu-toba/framework/www vendor/siu-toba/framework/temp"
echo "-- Permisos configurados"

echo "-- Instalando guarani"
docker exec -it $APACHE_CONTAINER bash -c "cd bin && ./guarani instalar"
echo "-- Guarani instalado"

