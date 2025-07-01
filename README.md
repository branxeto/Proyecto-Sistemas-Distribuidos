# Sistema de Procesamiento de Datos de Tráfico

## Descripción

Este proyecto implementa un sistema distribuido para el procesamiento y análisis de datos de tráfico urbano. El sistema utiliza **Apache Pig** y **Docker** para crear un pipeline de procesamiento de datos que incluye filtrado, análisis y almacenamiento en **Elasticsearch** con visualización en **Kibana**.

### Objetivos del Proyecto

- Procesar datos de tráfico obtenidos mediante scraping
- Filtrar y estandarizar información de incidentes y atascos
- Realizar análisis agregados por ciudad, tipo y subtipo
- Almacenar resultados en Elasticsearch para análisis
- Proporcionar dashboards de visualización con Kibana

---

## Arquitectura del Sistema

El sistema está compuesto por los siguientes componentes:

### Servicios de Infraestructura
- **Elasticsearch**: Base de datos para almacenar los datos procesados
- **Kibana**: Interfaz de visualización y análisis
- **Redis**: Cache y almacenamiento temporal
- **RedisInsight**: Interfaz de administración de Redis

### Servicios de Procesamiento
- **Filtering**: Filtrado y estandarización de datos crudos
- **Processing**: Análisis y agrupación de datos
- **DataInsert**: Inserción de datos procesados en Elasticsearch

---

## Estructura del Proyecto

``` proyecto-trafico/
├── docker-compose-tarea2.yml    # Configuración de servicios
├── start.sh                     # Script de ejecución principal
├── README.md                    # Documentación del proyecto
├── DataInsert/                  # Servicio de inserción de datos
│   ├── dockerfile
│   ├── entrypoint.sh
│   ├── InsertData.py            # Script de inserción a Elasticsearch
│   └── requerimientos.txt
├── Filtering/                   # Servicio de filtrado
│   ├── dockerfile
│   ├── Configuración/
│   │   ├── elephant-bird-*.jar  # Librerías para JSON en Pig
│   │   └── entrypoint.sh
│   ├── Datos/
│   │   └── DatosRaw.json        # Datos crudos de entrada
│   └── scripts/
│       └── filtrado.pig         # Script de filtrado Pig
├── Processing/                  # Servicio de procesamiento
│   ├── dockerfile
│   ├── Configuración/
│   │   ├── elasticsearch-hadoop-*.jar
│   │   ├── elephant-bird-*.jar
│   │   └── entrypoint.sh
│   └── scripts/
│       └── processing.pig       # Script de análisis Pig
└── resultado/                   # Resultados del procesamiento
    ├── atasco_final/
    ├── Atascos/
    ├── ciudad_atascos/
    ├── ciudad_incidentes/
    ├── Incidentes/
    ├── incidentes_final/
    ├── subtype_incidentes/
    ├── type_incidentes/
    └── type_subtype_incidentes/
```

---

## Instalación y Ejecución

### Requisitos Previos

- **Docker** (versión 20.10 o superior)
- **Docker Compose** (versión 2.0 o superior)
- **Sistema Operativo**: Linux/macOS/Windows con WSL2
- **Recursos mínimos**: 4GB RAM, 10GB espacio en disco

### Configuración Inicial

1. **Clonar o preparar el proyecto:**
   ```bash
   # Asegúrate de tener todos los archivos del proyecto
   ls -la
   ```

2. **Verificar permisos del script:**
   ```bash
   chmod +x start.sh
   ```

###  Ejecución del Sistema

1. **Ejecutar el sistema completo:**
   ```bash
   bash start.sh
   ```
   
   Este script realiza las siguientes acciones:
   - Limpia resultados previos
   - Construye todas las imágenes Docker
   - Ejecuta el pipeline completo de procesamiento
   - Muestra el tiempo total de ejecución

### Acceso a las Interfaces

Una vez ejecutado el sistema, puedes acceder a:

- **Kibana**: http://localhost:5601 - Visualización de datos
- **Elasticsearch**: http://localhost:9200 - API de búsqueda
- **RedisInsight**: http://localhost:5540 - Administración de Redis

---

## Pipeline de Procesamiento

### 1. Filtrado de Datos (`filtering`)

**Función**: Filtra y estandariza los datos crudos de tráfico

**Proceso**:
- Carga datos desde `DatosRaw.json` usando librerías Elephant Bird
- Filtra registros válidos (con campos requeridos no nulos)
- Separa incidentes y atascos
- Estandariza formatos de fecha y ubicación
- Genera archivos intermedios en `/resultado`

**Entrada**: `Filtering/Datos/DatosRaw.json`
**Salida**: 
- `/resultado/Incidentes/`
- `/resultado/Atascos/`

### 2. Procesamiento y Análisis (`processing`)

**Función**: Realiza análisis agregados y estadísticas

**Proceso**:
- Carga datos filtrados
- Agrupa por diferentes dimensiones:
  - Ciudad
  - Tipo de incidente
  - Subtipo de incidente
  - Combinaciones tipo-subtipo
- Calcula métricas estadísticas
- Genera reportes finales

**Entrada**: Archivos de `/resultado` del paso anterior
**Salida**:
- `atasco_final/` - Datos procesados de atascos
- `incidentes_final/` - Datos procesados de incidentes
- `ciudad_atascos/` - Atascos agrupados por ciudad
- `ciudad_incidentes/` - Incidentes agrupados por ciudad
- `type_incidentes/` - Incidentes por tipo
- `subtype_incidentes/` - Incidentes por subtipo
- `type_subtype_incidentes/` - Incidentes por tipo y subtipo

### 3. Inserción en Elasticsearch (`insert_data`)

**Función**: Almacena los datos procesados en Elasticsearch

**Proceso**:
- Lee archivos procesados
- Crea índices en Elasticsearch
- Inserta datos con mapping apropiado
- Actualiza cache Redis con estadísticas
- Valida la inserción correcta

**Salida**: Datos disponibles en Elasticsearch para consultas y visualización

---

## Tecnologías Utilizadas

### Core Technologies
- **Apache Pig**: Procesamiento de big data
- **Docker & Docker Compose**: Containerización y orquestación
- **Elasticsearch**: Motor de búsqueda y analytics
- **Kibana**: Visualización de datos
- **Redis**: Cache y almacenamiento temporal

### Librerías y Dependencias
- **Elephant Bird**: Procesamiento de JSON en Pig
- **Python Requests**: Cliente HTTP para APIs
- **Redis Python**: Cliente Redis para Python

---

## Datos y Formatos

### Formato de Datos de Entrada
```json
{
  "startTimeMillis": 1234567890,
  "jams": {
    "city": "Santiago",
    "street": "Av. Providencia",
    "endNode": "Plaza Baquedano",
    "line": [...],
    "causeAlert": {
      "location": {...},
      "type": "ACCIDENT",
      "subtype": "ACCIDENT_MINOR"
    }
  }
}
```

### Índices de Elasticsearch Generados
- `atascos`: Datos de atascos procesados
- `atascos_ciudad_atascos`: Agregados de atascos por ciudad
- `incidentes`: Datos de incidentes procesados
- `incidentes_ciudad_incidentes`: Agregados de incidentes por ciudad
- `incidentes_type_incidentes`: Incidentes agrupados por tipo
- `incidentes_subtype_incidentes`: Incidentes agrupados por subtipo
- `incidentes_type_subtype_incidentes`: Incidentes por tipo y subtipo


---

## Autores

- **[Branco Burotto](https://github.com/branxeto)** - Desarrollo principal
- **[Valentina García](https://github.com/balentula)** - Desarrollo y documentación