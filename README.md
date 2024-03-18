# Instalacion de SIU-Guarani 3 en Docker

Scripts para la instalación de sistema SIU-Guarani 3, gestión y autogestión.

**Solo para ambiente de desarrollo.**

Hecho con docker compose **Docker Compose version v2.20.2**

## SIU-Guarani 3 Gestión

Correr el script `install-g3.sh`

```bash
./install_g3.sh
```

- En ubicacion de PostgreSQL ingresar `postgres` en lugar de `localhost`
- En clave de PostgreSQL ingresar la clave *$POSTGRES_PASSWORD* de [.env](.env)
- "Desea agregar el alias de apache al archivo toba.conf? (Si o No)" ***Ingresar si***

**Para reutilizar una base colocarla en el directorio `/init` y no pisarla en la instalacion cuando ésta lo consulte**

## SIU-Guarani 3 Autogestión

Correr el script `install_g3w3.sh`

```bash
./install_g3w3.sh
```

## Uso

- antes de usar correr el siguiente comando para el funcionamiento de los reportes
```bash
./docker_exec.sh java -jar guarani/vendor/siu-toba/jasper/JavaBridge/WEB-INF/lib/JavaBridge.jar SERVLET_LOCAL:8081
```

- [guarani/](http://localhost/)

- [toba editor/](http://localhost/toba_editor/3.3)

- [guarani/filo](http://localhost/filo)

## Remover instalacion

Para volver a instalar (elimina volumenes y svn de guarani/g3w3) 

```bash
sudo ./uninstall.sh
```

## Utilidades

Se pueden correr comandos en el container de apache con el siguiente script `docker-exec.sh`

```bash
./docker_exec.sh [-flags] [comando]
```