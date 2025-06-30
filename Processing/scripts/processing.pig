-- CARGA DE DATOS
Incidentes = LOAD '/resultado/Incidentes' USING JsonLoader('lines:chararray,city:chararray,street:chararray,endNode:chararray,latitude:double,longitude:double,type:chararray,subtype:chararray,startTimeMillis:long,endTimeMillis:long,count:int');
Atascos = LOAD '/resultado/Atascos' USING JsonLoader('lines:chararray,city:chararray,street:chararray,endNode:chararray,startTimeMillis:long,endTimeMillis:long,count:int');
--DESCRIBE Incidentes;
-- DESCRIBE Atascos;

-- AGRUPACIÓN DE INCIDENTES U OTROS
Incidentes = FOREACH Incidentes GENERATE
    (chararray) city AS city,
    (chararray) street AS street,
    (chararray) endNode AS endNode,
    (double) latitude AS latitude,
    (double) longitude AS longitude,
    (chararray) type AS type,
    (chararray) subtype AS subtype,
    (long) startTimeMillis AS startTimeMillis,
    (long) endTimeMillis AS endTimeMillis,
    (int) count AS count,
    (chararray) lines AS line;
Incidentes = RANK Incidentes;
Incidentes = FOREACH Incidentes GENERATE
    rank_Incidentes AS id,
    city,
    street,
    endNode,
    latitude,
    longitude,
    type,
    subtype,
    startTimeMillis,
    endTimeMillis,
    count,
    line;

SplitlineIncidentes = FOREACH Incidentes GENERATE
    id,
    city,
    street,
    endNode,
    latitude,
    longitude,
    type,
    subtype,
    startTimeMillis,
    endTimeMillis,
    count,
    (STRSPLIT(line, '_')) as lines;
IncidentesFinal = FOREACH SplitlineIncidentes GENERATE
    id,
    city,
    street,
    endNode,
    latitude,
    longitude,
    type,
    subtype,
    startTimeMillis,
    endTimeMillis,
    count,
    FLATTEN(lines) AS lines;
IncidentesFinal = FOREACH IncidentesFinal GENERATE
    id,
    city,
    street,
    endNode,
    latitude,
    longitude,
    type,
    subtype,
    startTimeMillis,
    endTimeMillis,
    count,
    (FLOAT)REGEX_EXTRACT(lines, '\\{x=(-?\\d+\\.\\d+), y=(-?\\d+\\.\\d+)\\}', 1) AS lon, 
    (FLOAT)REGEX_EXTRACT(lines, '\\{x=(-?\\d+\\.\\d+), y=(-?\\d+\\.\\d+)\\}', 2) AS lat;
-- DESCRIBE Incidentes;
-- A = LIMIT Incidentes 10;
-- DUMP A;

CiudadIncidentes = GROUP IncidentesFinal BY city;
CiudadIncidentes = FOREACH CiudadIncidentes GENERATE
    group AS city,
    'CiudadIncidentes' AS index,
    IncidentesFinal;
--B = LIMIT CiudadIncidentesCount 10;
--DUMP B;

TypeIncidentes = GROUP IncidentesFinal BY type;
TypeIncidentes = FOREACH TypeIncidentes GENERATE
    group AS type,
    'TypeIncidentes' AS index,
    IncidentesFinal;
--D = LIMIT TypeIncidentesCount 10;
--DUMP D;

SubTypeIncidentes = GROUP IncidentesFinal BY subtype;
SubTypeIncidentes = FOREACH SubTypeIncidentes GENERATE
    group AS subtype,
    'SubTypeIncidentes' AS index,
    IncidentesFinal;
--E = LIMIT SubTypeIncidentesCount 10;
--DUMP E;

TypeSubtypeIncidentes = GROUP IncidentesFinal BY (type, subtype);
TypeSubtypeIncidentes = FOREACH TypeSubtypeIncidentes GENERATE
    group.type AS type,
    group.subtype AS subtype,
    'TypeSubtypeIncidentes' AS index,
    IncidentesFinal;
--F = LIMIT TypeSubtypeIncidentesCount 10;
--DUMP F;

-- AGRUPACIÓN DE ATASCOS
Atascos = FOREACH Atascos GENERATE
    (chararray) city AS city,
    (chararray) street AS street,
    (chararray) endNode AS endNode,
    (long) startTimeMillis AS startTimeMillis,
    (long) endTimeMillis AS endTimeMillis,
    (int) count AS count,
    (chararray) lines AS lines;
Atascos = RANK Atascos;
Atascos = FOREACH Atascos GENERATE
    rank_Atascos AS id,
    city,
    street,
    endNode,
    startTimeMillis,
    endTimeMillis,
    count,
    lines;
--DESCRIBE Atascos;
-- G = LIMIT Atascos 100;
-- DUMP G;

SplitlineAtascos = FOREACH Atascos GENERATE
    id,
    city,
    street,
    endNode,
    startTimeMillis,
    endTimeMillis,
    count,
    (STRSPLIT(lines, '_')) as lines;

AtascosFinal = FOREACH SplitlineAtascos GENERATE
    id,
    city,
    street,
    endNode,
    startTimeMillis,
    endTimeMillis,
    count,
    FLATTEN(lines) AS lines;
AtascoFinal = FOREACH AtascosFinal GENERATE
    id,
    city,
    street,
    endNode,
    startTimeMillis,
    endTimeMillis,
    count,
    (FLOAT)REGEX_EXTRACT(lines, '\\{x=(-?\\d+\\.\\d+), y=(-?\\d+\\.\\d+)\\}', 1) AS lon,  -- Longitud (x)
    (FLOAT)REGEX_EXTRACT(lines, '\\{x=(-?\\d+\\.\\d+), y=(-?\\d+\\.\\d+)\\}', 2) AS lat;  -- Latitud (y)
H = LIMIT AtascoFinal 10;
DUMP H;

-- Agrupación por ciudad
CiudadAtascos = GROUP AtascoFinal BY city;
CiudadAtascos = FOREACH CiudadAtascos GENERATE
    group AS city,
    'CiudadAtascos' AS index,
    AtascoFinal;
--H = LIMIT CiudadAtascosCount 10;
--DUMP H;

-- Guardado de los datos
STORE CiudadIncidentes INTO '../DatosAgrupados/ciudad_incidentes' USING JsonStorage();
STORE IncidentesFinal INTO '../DatosAgrupados/incidentes_final' USING JsonStorage();
STORE TypeIncidentes INTO '../DatosAgrupados/type_incidentes' USING JsonStorage();
STORE SubTypeIncidentes INTO '../DatosAgrupados/subtype_incidentes' USING JsonStorage();
STORE TypeSubtypeIncidentes INTO '../DatosAgrupados/type_subtype_incidentes' USING JsonStorage();
STORE AtascoFinal INTO '../DatosAgrupados/atasco_final' USING JsonStorage();
STORE CiudadAtascos INTO '../DatosAgrupados/ciudad_atascos' USING JsonStorage();