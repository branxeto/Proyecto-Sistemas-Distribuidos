REGISTER '/scripts/elephant-bird-pig-4.17.jar';
REGISTER '/scripts/elephant-bird-core-4.17.jar';
REGISTER '/scripts/elephant-bird-hadoop-compat-4.17.jar';

-- Cargar los datos desde un archivo JSON
DatosRaw = LOAD '../datos/DatosRaw.json' USING com.twitter.elephantbird.pig.load.JsonLoader('-nestedLoad');

-- FIltrar datos para obtener solo los validos
DatosRaw = FILTER DatosRaw BY 
    $0#'jams'#'causeAlert'#'location' IS NOT NULL AND
    $0#'jams'#'causeAlert'#'type' IS NOT NULL AND
    $0#'jams'#'causeAlert'#'subtype' IS NOT NULL AND
    $0#'jams'#'city' IS NOT NULL AND
    $0#'jams'#'street' IS NOT NULL AND
    $0#'startTime' IS NOT NULL;

-- Extraer los campos necesarios
DatosFiltrados = FOREACH DatosRaw GENERATE
    (chararray) $0#'startTime' AS startTime,
    (chararray) $0#'jams'#'city' AS city,
    (chararray) $0#'jams'#'street' AS street,
    (double) $0#'jams'#'causeAlert'#'location'#'x' as latitude,
    (double) $0#'jams'#'causeAlert'#'location'#'y' as longitude,
    (chararray) $0#'jams'#'causeAlert'#'type' AS Type,
    (chararray) $0#'jams'#'causeAlert'#'subtype' AS Subtype;
B = LIMIT DatosFiltrados 10;
DUMP B;

-- Almacenar los datos filtrados en un nuevo archivo
STORE DatosFiltrados INTO '../datoFiltrado' USING PigStorage(',');