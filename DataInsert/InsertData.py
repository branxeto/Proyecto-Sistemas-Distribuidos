import json
import requests

archivos = [
    '/resultado/atasco_final/part-m-00000',
    '/resultado/ciudad_atascos/part-r-00000',
    '/resultado/incidentes_final/part-m-00000',
    '/resultado/ciudad_incidentes/part-r-00000',
    '/resultado/type_incidentes/part-r-00000',
    '/resultado/subtype_incidentes/part-r-00000',
    '/resultado/type_subtype_incidentes/part-r-00000',
    ]
url_elastic = 'http://elasticsearch:9200/_bulk'

for i, archivo in enumerate(archivos):
    datos= []
    with open(archivo, 'r') as file:
        for j, line in enumerate(file, 1):
            line = line.strip()
            if not line:
                continue
            try:
                doc = json.loads(line)
                action = {} 
                if i == 0:
                    action = { "index": { "_index": "atascos", "_id": str(j) } }
                elif i == 1:
                    action = { "index": { "_index": "atascos_ciudad_atascos", "_id": str(j) } }
                elif i == 2:
                    action = { "index": { "_index": "incidentes", "_id": str(j) } }
                elif i == 3:
                    action = { "index": { "_index": "incidentes_ciudad_incidentes", "_id": str(j) } }
                elif i == 4:
                    action = { "index": { "_index": "incidentes_type_incidentes", "_id": str(j) } }
                elif i == 5:
                    action = { "index": { "_index": "incidentes_subtype_incidentes", "_id": str(j) } }
                elif i == 6:
                    action = { "index": { "_index": "incidentes_type_subtype_incidentes", "_id": str(j) } }
                else:
                    action = { "index": { "_index": "incidentes_type_subtype_incidentes", "_id": str(j) } }
                datos.append(json.dumps(action))
                datos.append(json.dumps(doc))

            except json.JSONDecodeError as e:
                print(f"Error en línea {i}: {line}\n{e}")
            
    datos_final = "\n".join(datos) + "\n"

    headers = { "Content-Type": "application/json" }
    response = requests.post(url_elastic, headers=headers, data=datos_final)

    if response.status_code == 200:
        print("Datos subidos correctamente")
        print(response.json())
    else:
        print(f"Error {response.status_code}")
        print(response.text)