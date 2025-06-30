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

echo "Archivos de datos encontrados. Procediendo a la creación de indices."

curl -X DELETE http://localhost:9200/incidentes_final
curl -X PUT "http://localhost:9200/incidentes_final" -H "Content-Type: application/json" -d '{
  "mappings": {
    "properties": {
      "location": { "type": "geo_point" }
    }
  }
}'

curl -X DELETE http://localhost:9200/atasco_final
curl -X PUT "http://localhost:9200/atasco_final" -H "Content-Type: application/json" -d '{
  "mappings": {
    "properties": {
      "location": { "type": "geo_point" }
    }
  }
}'

echo "Indices creados. Procediendo a insertar los datos."
pip install --no-cache-dir -r requerimientos.txt
python InsertData.py