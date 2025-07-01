import json
import requests
import redis 
import time

# Inserción de datos a elasticsearch
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
        
        
# Inserción de datos a redis
time.sleep(2)
cache = redis.Redis(host='redis', port=6379, decode_responses=True)
response = []
response.append(requests.post('http://elasticsearch:9200/atascos*/_async_search?batched_reduce_size=64&ccs_minimize_roundtrips=true&wait_for_completion_timeout=200ms&keep_on_completion=false&keep_alive=60000ms&ignore_unavailable=true',
    json={
  "aggs": {
    "0": {
      "terms": {
        "field": "AtascoFinal.city.keyword",
        "order": {
          "1": "desc"
        },
        "size": 300,
        "shard_size": 1000
      },
      "aggs": {
        "1": {
          "cardinality": {
            "field": "AtascoFinal.count"
          }
        }
      }
    }
  },
  "size": 0,
  "_source": {
    "excludes": []
  },
  "query": {
    "bool": {
      "must": [],
      "filter": [],
      "should": [],
      "must_not": []
    }
  },
  "stored_fields": [
    "*"
  ],
  "runtime_mappings": {},
  "script_fields": {},
  "fields": []
}))
cache.set('atascos_ciudad', json.dumps(response[0].json()))
response.append(requests.post('http://elasticsearch:9200/atascos*/_async_search?batched_reduce_size=64&ccs_minimize_roundtrips=true&wait_for_completion_timeout=200ms&keep_on_completion=false&keep_alive=60000ms&ignore_unavailable=true',
json={
  "aggs": {
    "0": {
      "terms": {
        "field": "AtascoFinal.street.keyword",
        "order": {
          "1.50": "desc"
        },
        "size": 50
      },
      "aggs": {
        "1": {
          "percentiles": {
            "field": "AtascoFinal.count",
            "percents": [
              50
            ]
          }
        }
      }
    }
  },
  "size": 0,
  "_source": {
    "excludes": []
  },
  "query": {
    "bool": {
      "must": [],
      "filter": [],
      "should": [],
      "must_not": []
    }
  },
  "stored_fields": [
    "*"
  ],
  "runtime_mappings": {},
  "script_fields": {},
  "fields": []
}))
cache.set('atascos_calle', json.dumps(response[1].json()))
response.append(requests.post('http://elasticsearch:9200/incidentes*/_async_search?batched_reduce_size=64&ccs_minimize_roundtrips=true&wait_for_completion_timeout=200ms&keep_on_completion=false&keep_alive=60000ms&ignore_unavailable=true',
  json={
  "aggs": {
    "0": {
      "terms": {
        "field": "IncidentesFinal.street.keyword",
        "order": {
          "1.50": "desc"
        },
        "size": 500
      },
      "aggs": {
        "1": {
          "percentiles": {
            "field": "IncidentesFinal.count",
            "percents": [
              50
            ]
          }
        }
      }
    }
  },
  "size": 0,
  "_source": {
    "excludes": []
  },
  "query": {
    "bool": {
      "must": [],
      "filter": [],
      "should": [],
      "must_not": []
    }
  },
  "stored_fields": [
    "*"
  ],
  "runtime_mappings": {},
  "script_fields": {},
  "fields": []
}))
cache.set('incidentes_ciudad', json.dumps(response[2].json()))
response.append(requests.post('http://elasticsearch:9200/incidentes*/_async_search?batched_reduce_size=64&ccs_minimize_roundtrips=true&wait_for_completion_timeout=200ms&keep_on_completion=false&keep_alive=60000ms&ignore_unavailable=true',
  json={
  "aggs": {
    "0": {
      "terms": {
        "field": "IncidentesFinal.street.keyword",
        "order": {
          "1": "desc"
        },
        "size": 300
      },
      "aggs": {
        "1": {
          "value_count": {
            "field": "IncidentesFinal.count"
          }
        }
      }
    }
  },
  "size": 0,
  "_source": {
    "excludes": []
  },
  "query": {
    "bool": {
      "must": [],
      "filter": [],
      "should": [],
      "must_not": []
    }
  },
  "stored_fields": [
    "*"
  ],
  "runtime_mappings": {},
  "script_fields": {},
  "fields": []
}))
cache.set('incidentes_calle', json.dumps(response[3].json()))
response.append(requests.post('http://elasticsearch:9200/incidentes*/_async_search?batched_reduce_size=64&ccs_minimize_roundtrips=true&wait_for_completion_timeout=200ms&keep_on_completion=false&keep_alive=60000ms&ignore_unavailable=true',
  json={
  "aggs": {
    "0": {
      "terms": {
        "field": "IncidentesFinal.type.keyword",
        "order": {
          "1": "desc"
        },
        "size": 3,
        "shard_size": 25
      },
      "aggs": {
        "1": {
          "value_count": {
            "field": "IncidentesFinal.count"
          }
        }
      }
    }
  },
  "size": 0,
  "_source": {
    "excludes": []
  },
  "query": {
    "bool": {
      "must": [],
      "filter": [],
      "should": [],
      "must_not": []
    }
  },
  "stored_fields": [
    "*"
  ],
  "runtime_mappings": {},
  "script_fields": {},
  "fields": []
}))
cache.set('incidentes_type', json.dumps(response[4].json()))