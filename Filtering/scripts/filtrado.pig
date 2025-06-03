REGISTER '/scripts/elephant-bird-pig-4.17.jar';
REGISTER '/scripts/elephant-bird-core-4.17.jar';
REGISTER '/scripts/elephant-bird-hadoop-compat-4.17.jar';

-- Cargar los datos desde un archivo JSON
DatosRaw = LOAD '../datos/DatosRaw.json' USING com.twitter.elephantbird.pig.load.JsonLoader('-nestedLoad');

-- ACCIDENTES U OTROS
-- Estandarización
DatosAccidentes = FILTER DatosRaw BY 
    $0#'startTimeMillis' IS NOT NULL AND
    $0#'jams'#'city' IS NOT NULL AND $0#'jams'#'city' != '' AND 
    $0#'jams'#'street' IS NOT NULL AND $0#'jams'#'street' != '' AND
    $0#'jams'#'endNode' IS NOT NULL AND $0#'jams'#'endNode' != '' AND
    $0#'jams'#'line' IS NOT NULL AND
    $0#'jams'#'causeAlert'#'location' IS NOT NULL AND
    $0#'jams'#'causeAlert'#'type' IS NOT NULL AND $0#'jams'#'causeAlert'#'type' != '' AND
    $0#'jams'#'causeAlert'#'subtype' IS NOT NULL AND $0#'jams'#'causeAlert'#'subtype' != '';

-- Agrupación
DatosAccidentesAgrupados = FOREACH DatosAccidentes GENERATE
    (long) $0#'startTimeMillis' AS startTimeMillis,
    (chararray) $0#'jams'#'city' AS city,
    (chararray) $0#'jams'#'street' AS street,
    (chararray) $0#'jams'#'endNode' AS endNode,
    $0#'jams'#'line' AS line: bag{tuple(x:double, y:double)},
    (double) $0#'jams'#'causeAlert'#'location'#'x' AS latitude,
    (double) $0#'jams'#'causeAlert'#'location'#'y' AS longitude,
    (chararray) $0#'jams'#'causeAlert'#'type' AS type,
    (chararray) $0#'jams'#'causeAlert'#'subtype' AS subtype;


-- Transformar los datos a unos que se puedan manejar mejor
DatosAccidentesAgrupados = FOREACH DatosAccidentesAgrupados GENERATE
    startTimeMillis,
    city,
    street,
    endNode,
    BagToString(line) AS line,
    latitude,
    longitude,
    type,
    subtype;
--DESCRIBE DatosAccidentesAgrupados;
--A = LIMIT DatosAccidentesAgrupados 10;
--DUMP A;

-- Agrupor por line
DatosAccidentesLine = GROUP DatosAccidentesAgrupados BY line;
--B = LIMIT DatosLine 10;
--DUMP B;
--DESCRIBE DatosLine;

DatosAccidentesFinal = FOREACH DatosAccidentesLine {
    Ordenado = ORDER DatosAccidentesAgrupados BY startTimeMillis ASC;
    GENERATE
        group AS line,
        MIN(Ordenado.city) AS city,
        MIN(Ordenado.street) AS street,
        MIN(Ordenado.endNode) AS endNode,
        MIN(Ordenado.latitude) AS latitude,
        MIN(Ordenado.longitude) AS longitude,
        MIN(Ordenado.type) AS type,
        MIN(Ordenado.subtype) AS subtype,
        MIN(Ordenado.startTimeMillis) AS startTimeMillis,
        MAX(Ordenado.startTimeMillis) AS endTimeMillis,
        (int) COUNT(Ordenado) AS count;
};
--DESCRIBE DatosFinal;
--E = LIMIT DatosFinal 10;
--DUMP E;

-- ATASCOS
-- Estandarización
DatosAtasco = FILTER DatosRaw BY 
    $0#'jams'#'city' IS NOT NULL AND $0#'jams'#'city' != '' AND 
    $0#'jams'#'street' IS NOT NULL AND $0#'jams'#'street' != '' AND
    $0#'jams'#'endNode' IS NOT NULL AND $0#'jams'#'endNode' != '' AND
    $0#'jams'#'causeAlert' IS NULL;


-- Extraer los campos necesarios
DatosAtascoAgrupados = FOREACH DatosAtasco GENERATE
    (long) $0#'startTimeMillis' AS startTimeMillis,
    (chararray) $0#'jams'#'city' AS city,
    (chararray) $0#'jams'#'street' AS street,
    (chararray) $0#'jams'#'endNode' AS endNode,
    $0#'jams'#'line' AS line: bag{tuple(x:double, y:double)};
--F = LIMIT DatosAtascoAgrupados 10;
--DUMP F;

DatosAtascoAgrupados = FOREACH DatosAtascoAgrupados GENERATE
    startTimeMillis,
    city,
    street,
    endNode,
    BagToString(line) AS line;
--G = LIMIT DatosAtascoAgrupados 10;
--DUMP G;

-- Agrupación por line
DatosAtascoLine = GROUP DatosAtascoAgrupados BY line;
--H = LIMIT DatosAtascoLine 10;
--DUMP H;

-- Juntar los datos por line
DatosAtascoFinal = FOREACH DatosAtascoLine {
    Ordenado = ORDER DatosAtascoAgrupados BY startTimeMillis ASC;
    GENERATE
        group AS line,
        MIN(Ordenado.city) AS city,
        MIN(Ordenado.street) AS street,
        MIN(Ordenado.endNode) AS endNode,
        MIN(Ordenado.startTimeMillis) AS startTimeMillis,
        MAX(Ordenado.startTimeMillis) AS endTimeMillis,
        (int) COUNT(Ordenado) AS count;
};
--I = LIMIT DatosAtascoFinal 10;
--DUMP I;

-- Almacenar los datos filtrados en un nuevo archivo
STORE DatosAccidentesFinal INTO '../datoFiltrado/Incidentes' USING JsonStorage();
STORE DatosAtascoFinal INTO '../datoFiltrado/Atascos' USING JsonStorage();
