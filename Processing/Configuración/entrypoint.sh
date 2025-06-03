#!/bin/bash
set -e

export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# Código en bucle para esperar a que se generen los archivos de en contenedor Filtering
DATA_DIR="/resultado"
elapsed=0
while [ "$(find $DATA_DIR -type f | wc -l)" -eq 0 ]; do
    echo "Esperando a que se generen los archivos de datos..."
    sleep 5
    elapsed=$((elapsed + 5))
    if [ $elapsed -ge 300 ]; then
        echo "Tiempo de espera agotado. Saliendo."
        exit 1
    fi
done

# Ejecutar filtrado.pig
pig -x local /scripts/processing.pig

# move resultados a la carpeta de resultados
mv /DatosAgrupados/* /resultado
