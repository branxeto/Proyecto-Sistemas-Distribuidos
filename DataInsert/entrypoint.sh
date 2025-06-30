#!/bin/bash
DATA_DIR="/resultado/atasco_final" 
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

pip install --no-cache-dir -r requerimientos.txt
python InsertData.py