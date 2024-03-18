#!/bin/bash

# Función para imprimir mensajes de color amarillo
echo_yellow() {
    YELLOW='\033[1;33m'  # Color amarillo
    NC='\033[0m'         # Volver al color predeterminado
    echo -e "${YELLOW}$@${NC}"
}

# Función para ejecutar comandos dentro del contenedor Apache
exec_in_apache_container() {
    docker exec -it $APACHE_CONTAINER bash -c "cd ${GUARANI_AUTOGESTION_DIR} && $@"
}

if [ -f ".env" ]; then
    source .env
fi

echo_yellow "-- Configurando permisos"
exec_in_apache_container "chown -R www-data:www-data instalacion/log/ instalacion/cache/ instalacion/temp/ instalacion/operaciones_inactivas/ src/siu/www/js/escalas/ src/siu/www/temp/"
exec_in_apache_container "chmod 775 -R instalacion/log/ instalacion/cache/ instalacion/temp/ instalacion/operaciones_inactivas/ src/siu/www/js/escalas/ src/siu/www/temp/"
echo_yellow "-- Permisos configurados"

echo_yellow "-- Levantando archivos de configuracion"
exec_in_apache_container "cp ${GUARANI_AUTOGESTION_DIR}instalacion/alias_template.conf ${GUARANI_AUTOGESTION_DIR}instalacion/alias.conf"
exec_in_apache_container "cp ${GUARANI_AUTOGESTION_DIR}instalacion/config_template.php ${GUARANI_AUTOGESTION_DIR}instalacion/config.php"
exec_in_apache_container "cp ${GUARANI_AUTOGESTION_DIR}instalacion/login_template.php ${GUARANI_AUTOGESTION_DIR}instalacion/login.php"
echo_yellow "-- Archivos copiados"

echo_yellow "-- Ejecutando 'composer install'"
exec_in_apache_container "composer install --no-interaction --optimize-autoloader -d ${GUARANI_AUTOGESTION_DIR}"
echo_yellow "-- 'composer install' finalizado"

echo_yellow "-- Copiando archivo config.php"
docker cp config/config.php ${APACHE_CONTAINER}:${GUARANI_AUTOGESTION_DIR}instalacion/config.php
echo_yellow "-- Archivo config.php copiado"

echo_yellow "-- Levantando sitio"
exec_in_apache_container "a2ensite alias.conf"
exec_in_apache_container "service apache2 reload"
echo_yellow "-- Sitio levantado"
