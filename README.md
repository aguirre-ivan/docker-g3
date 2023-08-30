# Instalacion de Guarani3

Solo para ambiente de desarrollo

Hecho con docker compose **Docker Compose version v2.20.2**

## Ejecutar

```bash
./install_g3.sh
```

- En ubicacion de PostgreSQL ingresar `postgres` en lugar de `localhost`
- En clave de PostgreSQL ingresar la clave *$POSTGRES_PASSWORD* de [.env](.env)
- "Desea agregar el alias de apache al archivo toba.conf? (Si o No)" ***Ingresar si***

## Remover instalacion

Para volver a instalar (elimina volumenes y svn de guarani) 

```bash
sudo ./uninstall_g3.sh
```

## Uso

[guarani/](http://localhost/)
[toba editor/](http://localhost/toba_editor/3.3)