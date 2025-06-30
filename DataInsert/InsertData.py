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
indices = [
    "atascos",
    "atascos_ciudad_atascos",
    "incidentes",
    "incidentes_ciudad_incidentes",
    "incidentes_type_incidentes",
    "incidentes_subtype_incidentes",
    "incidentes_type_subtype_incidentes"
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
                if 'lat' in doc and 'lon' in doc:
                    doc['location'] = {
                        'lat': float(doc.pop('lat')),
                        'lon': float(doc.pop('lon'))
                    }
                action = { "index": { "_index": indices[i], "_id": str(j) } }
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