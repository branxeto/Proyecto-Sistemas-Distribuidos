#!/bin/bash

# Ejecutar filtrado.pig
pig -x local /scripts/Filtrado.pig

# move resultados a la carpeta de resultados
mv /datoFiltrado/* /resultado

#Mantener vivo el contenedor
exec /bin/bash