#!/bin/bash
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# Ejecutar filtrado.pig
pig -x local /scripts/Filtrado.pig

# move resultados a la carpeta de resultados
mv /datoFiltrado/* /resultado