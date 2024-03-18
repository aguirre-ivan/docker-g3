#!/bin/bash

# Función para imprimir mensajes en color rojo
echo_red() {
    RED='\033[0;31m'  # Color rojo
    NC='\033[0m'       # Volver al color predeterminado
    echo -e "${RED}$@${NC}"
}

echo_red "-- Bajando contenedores"
docker compose down
echo_red "-- Contenedores bajados"

echo_red "-- Borrando svn de guarani si existe"
rm -rf guarani
echo_red "-- svn borrado"

echo_red "-- Borrando volumen de postgres si existe"
rm -rf pg_data
echo_red "-- volumen borrado"