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
docker exec -i $APACHE_CONTAINER composer install --no-interaction --optimize-autoloader -d ${GUARANI_GESTION_DIR}
echo "-- 'composer install' finalizado"

DUMP_DIR="$PWD/init"
FILE_DUMP=$(ls -1 "$DUMP_DIR" | head -n 1)

echo "-- Aumentando max_locks_per_transaction"
docker exec -it $POSTGRES_CONTAINER bash -c "cd /var/lib/postgresql/data && sed -i 's/^#max_locks_per_transaction = .*/max_locks_per_transaction = 1024/' postgresql.conf"
docker restart $POSTGRES_CONTAINER
echo "-- Aguardando reinicio de postgres"
sleep 10s
echo "-- max_locks_per_transaction aumentado"

echo "-- Cargando esquemas (si existe dump)"
if [ -n "$FILE_DUMP" ]; then
    FILE_DUMP="$DUMP_DIR/$FILE_DUMP"
    echo "-- Cargando el primer archivo de dump: $FILE_DUMP"
    PGPASSWORD=$POSTGRES_PASSWORD docker exec -i $POSTGRES_CONTAINER dropdb -U $POSTGRES_USER -h localhost -p 5432 $POSTGRES_DB
    PGPASSWORD=$POSTGRES_PASSWORD docker exec -i $POSTGRES_CONTAINER createdb -U $POSTGRES_USER -h localhost -p 5432 $POSTGRES_DB
    PGPASSWORD=$POSTGRES_PASSWORD docker exec -i $POSTGRES_CONTAINER psql -h localhost -p 5432 -U $POSTGRES_USER -d $POSTGRES_DB < $FILE_DUMP
    echo "-- Dump cargado"
else
    echo "-- No se encontraron archivos de dump en $DUMP_DIR. No se realizó la carga."
fi

echo "-- Instalando framework toba"
docker exec -it $APACHE_CONTAINER bash -c "cd ${GUARANI_GESTION_DIR}bin && export TOBA_INSTANCIA=desarrollo"
docker exec -it $APACHE_CONTAINER bash -c "cd ${GUARANI_GESTION_DIR}bin && export TOBA_INSTALACION_DIR=${GUARANI_GESTION_DIR}instalacion"
docker exec -it $APACHE_CONTAINER bash -c "cd ${GUARANI_GESTION_DIR}bin && ./toba instalacion instalar"
echo "-- Framework toba instalado"

echo "-- Configurando permisos"
docker exec -it $APACHE_CONTAINER bash -c "cd ${GUARANI_GESTION_DIR} && chown -R www-data:www-data www temp instalacion vendor/siu-toba/framework/www vendor/siu-toba/framework/temp ${TOBA_CONF_DIR}"
docker exec -it $APACHE_CONTAINER bash -c "cd ${GUARANI_GESTION_DIR} && chmod 775 -R www temp instalacion vendor/siu-toba/framework/www vendor/siu-toba/framework/temp"
echo "-- Permisos configurados"

echo "-- Levantando configuracion de sitio"
docker exec -it $APACHE_CONTAINER bash -c "a2dissite 000-default.conf"
docker exec -it $APACHE_CONTAINER bash -c "a2ensite toba_3_3.conf"
docker exec -it $APACHE_CONTAINER bash -c "service apache2 reload"  
echo "-- Configuracion ok"

echo "-- Agregar los parámetros de localización de fop"
docker exec -it $APACHE_CONTAINER bash -c "echo '
url3w = "https://localhost/filo"
[xslfo]
fop=${GUARANI_GESTION_DIR}php/3ros/fop/fop
' >> ${GUARANI_GESTION_DIR}instalacion/instalacion.ini"
echo "-- Parametros agregados"

echo "--"
docker exec -it $APACHE_CONTAINER bash -c "cp ${GUARANI_GESTION_DIR}menu.ini.tmpl ${GUARANI_GESTION_DIR}menu.ini"
docker exec -it $APACHE_CONTAINER bash -c "cd ${GUARANI_GESTION_DIR}bin && ./guarani cargar -d ${GUARANI_GESTION_DIR}"
docker exec -it $APACHE_CONTAINER bash -c "service apache2 reload"
echo "--"

echo "-- Configurando permisos"
docker exec -it $APACHE_CONTAINER bash -c "cd ${GUARANI_GESTION_DIR} && chown -R www-data:www-data www temp instalacion vendor/siu-toba/framework/www vendor/siu-toba/framework/temp ${TOBA_CONF_DIR}"
docker exec -it $APACHE_CONTAINER bash -c "cd ${GUARANI_GESTION_DIR} && chmod 775 -R www temp instalacion vendor/siu-toba/framework/www vendor/siu-toba/framework/temp"
echo "-- Permisos configurados"

echo "-- Instalando guarani"
docker exec -it $APACHE_CONTAINER bash -c "cd ${GUARANI_GESTION_DIR}bin && ./guarani instalar"
echo "-- Guarani instalado"

echo "-- Configurando permisos de carpeta instalacion"
docker exec -it $APACHE_CONTAINER bash -c "cd ${GUARANI_GESTION_DIR} && chmod 777 -R instalacion"
echo "-- Permisos configurados"

echo "-- Configurando permisos carpeta temp guarani"
docker exec -it $APACHE_CONTAINER bash -c "chmod 777 -R /dev/shm"
docker exec -it $APACHE_CONTAINER bash -c "chmod 777 -R /usr/local/proyectos/guarani/temp"
echo "-- Permisos OK"

echo "-- Creacion de log4j.properties"
docker exec -it $APACHE_CONTAINER bash -c "touch /usr/lib/jvm/java-11-openjdk-amd64/conf/security/log4j.properties"
echo "-- Creacion completada"

echo "-- Agregando parametro log4j.properties"
docker exec -it $APACHE_CONTAINER bash -c "echo '
log4j.rootLogger=debug, R

log4j.appender.R=org.apache.log4j.ConsoleAppender
log4j.appender.R.layout=org.apache.log4j.PatternLayout
log4j.appender.R.layout.ConversionPattern=%p %t %c - %m%n

' >> /usr/lib/jvm/java-11-openjdk-amd64/conf/security/log4j.properties"
echo "-- Parametro agregado"

echo "-- Clonando repositorio de Jasper"
docker exec -it $APACHE_CONTAINER bash -c "cd ${JASPER_DIR}/ && git clone ${JASPER_REPO}"
echo "-- Repositorio de Jasper clonado"

echo "-- Cambiando clave a toba"
    PGPASSWORD=$POSTGRES_PASSWORD docker exec -i $POSTGRES_CONTAINER psql -h localhost -p 5432 -U $POSTGRES_USER -d $POSTGRES_DB -c "UPDATE negocio.mdp_personas SET clave = '${TOBA_PASSWORD}' WHERE persona = 1;"
echo "-- Clave cambiada"