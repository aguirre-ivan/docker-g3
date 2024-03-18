#!/bin/bash

# Función para imprimir mensajes de color
echo_yellow() {
    YELLOW='\033[1;33m'  # Color amarillo
    NC='\033[0m'         # Volver al color predeterminado
    echo -e "${YELLOW}$@${NC}"
}

# Función para ejecutar comandos dentro del contenedor Apache
exec_in_apache_container() {
    docker exec -it $APACHE_CONTAINER bash -c "cd ${GUARANI_GESTION_DIR} && $@"
}

if [ -f ".env" ]; then
    source .env
fi

echo_yellow "-- Clonando svn de guarani"
svn checkout https://colab.siu.edu.ar/svn/guarani3/nodos/$SIGLAS_INSTITUCION/gestion/trunk/$G_VERSION guarani
echo_yellow "-- svn clonado"

echo_yellow "-- Clonando svn de autogestion"
svn checkout http://colab.siu.edu.ar/svn/guarani3/nodos/$SIGLAS_INSTITUCION/3w/trunk/$G_VERSION g3w3
echo_yellow "-- svn clonado"

echo_yellow "-- Levantando contenedores"
docker compose up -d
echo_yellow "-- Contenedores ok"

echo_yellow "-- Ejecutando 'composer install'"
exec_in_apache_container "composer install --no-interaction --optimize-autoloader -d ${GUARANI_GESTION_DIR}"
echo_yellow "-- 'composer install' finalizado"

DUMP_DIR="$PWD/init"
FILE_DUMP=$(ls -1 "$DUMP_DIR" | head -n 1)

echo_yellow "-- Aumentando max_locks_per_transaction"
docker exec -it $POSTGRES_CONTAINER bash -c "cd /var/lib/postgresql/data && sed -i 's/^#max_locks_per_transaction = .*/max_locks_per_transaction = 1024/' postgresql.conf"
docker restart $POSTGRES_CONTAINER
echo_yellow "-- Aguardando reinicio de postgres"
sleep 10s
echo_yellow "-- max_locks_per_transaction aumentado"

echo_yellow "-- Cargando esquemas (si existe dump)"
if [ -n "$FILE_DUMP" ]; then
    FILE_DUMP="$DUMP_DIR/$FILE_DUMP"
    echo_yellow "-- Cargando el primer archivo de dump: $FILE_DUMP"
    PGPASSWORD=$POSTGRES_PASSWORD docker exec -i $POSTGRES_CONTAINER dropdb -U $POSTGRES_USER -h localhost -p 5432 $POSTGRES_DB
    PGPASSWORD=$POSTGRES_PASSWORD docker exec -i $POSTGRES_CONTAINER createdb -U $POSTGRES_USER -h localhost -p 5432 $POSTGRES_DB
    PGPASSWORD=$POSTGRES_PASSWORD docker exec -i $POSTGRES_CONTAINER psql -h localhost -p 5432 -U $POSTGRES_USER -d $POSTGRES_DB < $FILE_DUMP
    echo_yellow "-- Dump cargado"
else
    echo_yellow "-- No se encontraron archivos de dump en $DUMP_DIR. No se realizó la carga."
fi

echo_yellow "-- Instalando framework toba"
exec_in_apache_container "cd ${GUARANI_GESTION_DIR}bin && export TOBA_INSTANCIA=desarrollo"
exec_in_apache_container "cd ${GUARANI_GESTION_DIR}bin && export TOBA_INSTALACION_DIR=${GUARANI_GESTION_DIR}instalacion"
exec_in_apache_container "cd ${GUARANI_GESTION_DIR}bin && ./toba instalacion instalar"
echo_yellow "-- Framework toba instalado"

echo_yellow "-- Configurando permisos"
exec_in_apache_container "chown -R www-data:www-data www temp instalacion vendor/siu-toba/framework/www vendor/siu-toba/framework/temp ${TOBA_CONF_DIR}"
exec_in_apache_container "chmod 775 -R www temp instalacion vendor/siu-toba/framework/www vendor/siu-toba/framework/temp"
echo_yellow "-- Permisos configurados"

echo_yellow "-- Levantando configuracion de sitio"
exec_in_apache_container "a2dissite 000-default.conf"
exec_in_apache_container "a2ensite toba_3_3.conf"
exec_in_apache_container "service apache2 reload"  
echo_yellow "-- Configuracion ok"

echo_yellow "-- Agregar los parámetros de localización de fop"
exec_in_apache_container "echo '
url3w = \"https://localhost/filo\"
[xslfo]
fop=${GUARANI_GESTION_DIR}php/3ros/fop/fop
' >> ${GUARANI_GESTION_DIR}instalacion/instalacion.ini"
echo_yellow "-- Parametros agregados"

echo_yellow "-- Copiando template de menu"
exec_in_apache_container "cp ${GUARANI_GESTION_DIR}menu.ini.tmpl ${GUARANI_GESTION_DIR}menu.ini"
echo_yellow "-- Template de menu copiado"

echo_yellow "-- Ejecutando './guarani cargar'"
exec_in_apache_container "cd ${GUARANI_GESTION_DIR}bin && ./guarani cargar -d ${GUARANI_GESTION_DIR}"
exec_in_apache_container "service apache2 reload"
echo_yellow "-- './guarani cargar' finalizado"

echo_yellow "-- Configurando permisos"
exec_in_apache_container "chown -R www-data:www-data www temp instalacion vendor/siu-toba/framework/www vendor/siu-toba/framework/temp ${TOBA_CONF_DIR}"
exec_in_apache_container "chmod 775 -R www temp instalacion vendor/siu-toba/framework/www vendor/siu-toba/framework/temp"
echo_yellow "-- Permisos configurados"

echo_yellow "-- Instalando guarani"
exec_in_apache_container "cd ${GUARANI_GESTION_DIR}bin && ./guarani instalar"
echo_yellow "-- Guarani instalado"

echo_yellow "-- Configurando permisos de carpeta instalacion"
exec_in_apache_container "chmod 777 -R instalacion"
echo_yellow "-- Permisos configurados"

echo_yellow "-- Configurando permisos carpeta temp guarani"
exec_in_apache_container "chmod 777 -R /dev/shm"
exec_in_apache_container "chmod 777 -R /usr/local/proyectos/guarani/temp"
echo_yellow "-- Permisos OK"

echo_yellow "-- Creacion de log4j.properties"
exec_in_apache_container "touch /usr/lib/jvm/java-11-openjdk-amd64/conf/security/log4j.properties"
echo_yellow "-- Creacion completada"

echo_yellow "-- Agregando parametro log4j.properties"
exec_in_apache_container "echo '
log4j.rootLogger=debug, R

log4j.appender.R=org.apache.log4j.ConsoleAppender
log4j.appender.R.layout=org.apache.log4j.PatternLayout
log4j.appender.R.layout.ConversionPattern=%p %t %c - %m%n

' >> /usr/lib/jvm/java-11-openjdk-amd64/conf/security/log4j.properties"
echo_yellow "-- Parametro agregado"

echo_yellow "-- Clonando repositorio de Jasper"
exec_in_apache_container "cd ${JASPER_DIR}/ && git clone ${JASPER_REPO}"
echo_yellow "-- Repositorio de Jasper clonado"

echo_yellow "-- Cambiando clave a toba"
    PGPASSWORD=$POSTGRES_PASSWORD docker exec -i $POSTGRES_CONTAINER psql -h localhost -p 5432 -U $POSTGRES_USER -d $POSTGRES_DB -c "UPDATE negocio.mdp_personas SET clave = '${TOBA_PASSWORD}' WHERE persona = 1;"
echo_yellow "-- Clave cambiada"
