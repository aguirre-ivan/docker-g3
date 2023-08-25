# Instalacion de Guarani3

Poner <siglas institución>:
```bash
siglas_institucion=uba-ffyl
version=3.21.0
```

```bash
svn checkout https://colab.siu.edu.ar/svn/guarani3/nodos/$siglas_institucion/gestion/trunk/$version guarani
```

```bash
docker compose up -d \
    && ./init_script.sh
```