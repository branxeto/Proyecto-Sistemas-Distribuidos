# Proyecto Sistemas Distribuidos - Entrega 2

## Descripción

Está entrega procesa información de tráfico obtenida por un scrapper (Entrega 1) utilizando **Apache Pig** y contenedores Docker. El flujo consiste en dos etapas principales:

1. **Filtrado y estandarización de datos** (contenedor `filtrado`)
2. **Agrupación y análisis de datos** (contenedor `procesamiento`)

Ambos contenedores se organizan mediante **Docker Compose** y comparten información a través de un volumen común **/resultado**.

---

## Estructura del Proyecto

```
├── Filtering/
│   ├── Datos/
│   ├── Configuración/
│   ├── scripts/
│   └── dockerfile
├── Processing/
│   ├── Datos/
│   ├── Configuración/
│   ├── scripts/
│   └── dockerfile
├── resultado/
├── docker-compose-tarea2.yml
└── start.sh
```

---

## Ejecución

### 1. Requisitos

- [Docker](https://www.docker.com/)
- [Docker Compose](https://docs.docker.com/compose/)
- [Imagen hadoop-pig](https://hub.docker.com/r/fluddeni/hadoop-pig)

### 2. Instrucciones

1. **Vacía la carpeta de resultados y construye/levanta los contenedores:**

   ```bash
   bash start.sh
   ```

   > Esto ejecuta el filtrado y procesamiento de los datos automáticamente. Ya que este ejecutable contiene la creación y ejecución del Docker-compose.

2. **Verifica los resultados**  
   Los archivos procesados y agrupados se encontrarán en la carpeta `resultado/` y subcarpetas generadas por los scripts Pig.

   En caso de que se haya ejecutado en terminal, se podran ver los logs asi mismos sin necesidad de realizar escribir un comando adicional.

---

## Detalles de los Contenedores

### Filtering

- **Función:** Filtra y estandariza los datos crudos obtenidos por el scrapper.
- **Entrada:** `Filtering/Datos/DatosRaw.json`
- **Ejecución:** `Filtering/scripts/filtrado.pig`
- **Salida:** Archivos filtrados en la carpeta `resultado/`

>En el código de pig se utilizan las librerias de [elephant-bird](https://github.com/twitter/elephant-bird) para cargar los datos de tipo JSON, esto debido a que pig no puede hacer LOAD de un JSON dinmico.

### Processing

- **Función:** Agrupa y analiza los datos filtrados por ciudad, tipo, subtipo, etc.
- **Entrada:** Archivos de la carpeta `resultado/` generados por el filtrado.
- **Salida:** Archivos agrupados en subcarpetas dentro de `resultado/`

---

## Autor

- [Branco Burotto](https://github.com/branxeto)
- [Valentina García](https://github.com/balentula)