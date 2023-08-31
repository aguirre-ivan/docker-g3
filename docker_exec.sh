#!/bin/bash

if [ -f ".env" ]; then
    source .env
fi

flag_i=false
flag_t=false
command=""

echo_help() {
    echo "Uso: $0 [-i] [-t] comando exec"
    echo "Descripción: Script para ejecutar 'docker exec' en el contenedor"
    echo "Opciones:"
    echo "  -i           Interactivo."
    echo "  -t           Asignación de terminal."
}

while getopts ":ith" flag; do
    case $flag in
        i)
            flag_i=true
            ;;
        t)
            flag_t=true
            ;;
        h)
            echo_help
            exit 0
            ;;
        \?)
            echo "Opción inválida: -$OPTARG. Usa -h para ver la ayuda." >&2
            exit 1
            ;;
    esac
done

shift $((OPTIND - 1))

if [ $# -gt 0 ]; then
    command="$@"
else
    echo "Se requiere un comando después de las opciones."
    exit 1
fi

if [ "$flag_i" = true ] && [ "$flag_t" = true ]; then
    docker exec -it $APACHE_CONTAINER $command
elif [ "$flag_t" = true ]; then
    docker exec -t $APACHE_CONTAINER $command
elif [ "$flag_i" = true ]; then
    docker exec -i $APACHE_CONTAINER $command
else
    docker exec $APACHE_CONTAINER $command
fi
