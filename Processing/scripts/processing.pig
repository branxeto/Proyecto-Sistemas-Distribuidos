-- CARGA DE DATOS
Incidentes = LOAD '/resultado/Incidentes' USING JsonLoader('lines:chararray,city:chararray,street:chararray,endNode:chararray,latitude:double,longitude:double,type:chararray,subtype:chararray,startTimeMillis:long,endTimeMillis:long,count:int');
Atascos = LOAD '/resultado/Atascos' USING JsonLoader('lines:chararray,city:chararray,street:chararray,endNode:chararray,startTimeMillis:long,endTimeMillis:long,count:int');
-- DESCRIBE Incidentes;
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
-- DESCRIBE Incidentes;
-- A = LIMIT Incidentes 10;
-- DUMP A;

CiudadIncidentes = GROUP Incidentes BY city;
CiudadIncidentesCount = FOREACH CiudadIncidentes GENERATE
    group AS city,
    SUM(Incidentes.count) AS count;
--B = LIMIT CiudadIncidentesCount 1000;
--DUMP B;

TypeIncidentes = GROUP Incidentes BY type;
TypeIncidentesCount = FOREACH TypeIncidentes GENERATE
    group AS type,
    SUM(Incidentes.count) AS count;
--D = LIMIT TypeIncidentesCount 100;
--DUMP D;

SubTypeIncidentes = GROUP Incidentes BY subtype;
SubTypeIncidentesCount = FOREACH SubTypeIncidentes GENERATE
    group AS subtype,
    SUM(Incidentes.count) AS count;
--E = LIMIT SubTypeIncidentesCount 100;
--DUMP E;

TypeSubtypeIncidentes = GROUP Incidentes BY (type, subtype);
TypeSubtypeIncidentesCount = FOREACH TypeSubtypeIncidentes GENERATE
    group AS type_subtype,
    SUM(Incidentes.count) AS count;
--F = LIMIT TypeSubtypeIncidentesCount 100;
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
-- DESCRIBE Atascos;
-- G = LIMIT Atascos 10;
-- DUMP G;

-- Agrupación por ciudad
CiudadAtascos = GROUP Atascos BY city;
CiudadAtascosCount = FOREACH CiudadAtascos GENERATE
    group AS city,
    SUM(Atascos.count) AS count;
--H = LIMIT CiudadAtascosCount 10;
--DUMP H;

-- Guardado de los datos
STORE CiudadIncidentes INTO '../DatosAgrupados/ciudad_incidentes' USING JsonStorage();
STORE CiudadIncidentesCount INTO '../DatosAgrupados/ciudad_incidentes_count' USING JsonStorage();

STORE TypeIncidentes INTO '../DatosAgrupados/type_incidentes' USING JsonStorage();
STORE TypeIncidentesCount INTO '../DatosAgrupados/type_incidentes_count' USING JsonStorage();

STORE SubTypeIncidentes INTO '../DatosAgrupados/subtype_incidentes' USING JsonStorage();
STORE SubTypeIncidentesCount INTO '../DatosAgrupados/subtype_incidentes_count' USING JsonStorage();

STORE TypeSubtypeIncidentes INTO '../DatosAgrupados/type_subtype_incidentes' USING JsonStorage();
STORE TypeSubtypeIncidentesCount INTO '../DatosAgrupados/type_subtype_incidentes_count' USING JsonStorage();

STORE CiudadAtascos INTO '../DatosAgrupados/ciudad_atascos' USING JsonStorage();
STORE CiudadAtascosCount INTO '../DatosAgrupados/ciudad_atascos_count' USING JsonStorage();