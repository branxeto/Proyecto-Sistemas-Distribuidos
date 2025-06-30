echo 'Esperando que Elasticsearch esté disponible...'
until curl -s http://elasticsearch:9200 >/dev/null; do
    sleep 2;
done;
echo 'Elasticsearch está disponible. Creando índices...';
curl -X PUT "http://elasticsearch:9200/incidentes" -H "Content-Type: application/json" -d '{"settings": {"number_of_shards": 1, "number_of_replicas": 0}}';
curl -X PUT "http://elasticsearch:9200/atascos" -H "Content-Type: application/json" -d '{"settings": {"number_of_shards": 1, "number_of_replicas": 0}}';
echo 'Índices creados.';


wait_for_file() {
local file=$1
while [ ! -f "$file" ]; do
    echo "Esperando a que el archivo $file esté disponible..."
    sleep 1
done
}

echo 'Ingresando datos';

wait_for_file "/resultado/atasco_final/part-m-00000"
curl -X POST "http://elasticsearch:9200/atascos/atascos" -H "Content-Type: application/json" --data-binary @"/resultado/atasco_final/part-m-00000"

wait_for_file "/resultado/ciudad_atascos/part-r-00000"
curl -X POST "http://elasticsearch:9200/atascos/ciudad_atascos" -H "Content-Type: application/json" --data-binary @"/resultado/ciudad_atascos/part-r-00000"

wait_for_file "/resultado/incidentes_final/part-m-00000"
curl -X POST "http://elasticsearch:9200/incidentes/incidentes" -H "Content-Type: application/json" --data-binary @"/resultado/incidentes_final/part-m-00000"

wait_for_file "/resultado/ciudad_incidentes/part-r-00000"
curl -X POST "http://elasticsearch:9200/incidentes/ciudad_incidentes" -H "Content-Type: application/json" --data-binary @"/resultado/ciudad_incidentes/part-r-00000"

wait_for_file "/resultado/subtype_incidentes/part-r-00000"
curl -X POST "http://elasticsearch:9200/incidentes/subtype_incidentes" -H "Content-Type: application/json" --data-binary @"/resultado/subtype_incidentes/part-r-00000"

wait_for_file "/resultado/type_incidentes/part-r-00000"
curl -X POST "http://elasticsearch:9200/incidentes/type_incidentes" -H "Content-Type: application/json" --data-binary @"/resultado/type_incidentes/part-r-00000"

wait_for_file "/resultado/type_subtype_incidentes/part-r-00000"
curl -X POST "http://elasticsearch:9200/incidentes/type_subtype_incidentes" -H "Content-Type: application/json" --data-binary @"/resultado/type_subtype_incidentes/part-r-00000"