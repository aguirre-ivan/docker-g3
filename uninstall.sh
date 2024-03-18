#!/bin/bash

echo "-- Bajando contenedores"
docker compose down
echo "-- Contenedores bajados"

echo "-- Borrando svn de guarani"
rm -r guarani
echo "-- svn borrado"

echo "-- Borrando volumen de postgres"
rm -r pg_data
echo "-- volumen borrado"