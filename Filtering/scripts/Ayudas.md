
-- Ordenar todos los datos por línea y tiempo de inicio
DatosOrdenados = ORDER DatosAccidentesAgrupados BY 
    startTimeMillis ASC;
DESCRIBE DatosOrdenados;
--B = LIMIT DatosOrdenados 60;
--DUMP B;

-- Agrupor por Líne
DatosLine = GROUP DatosAccidentesAgrupados BY line;
--C = LIMIT DatosLine 10;
--DUMP C;
--DESCRIBE DatosLine;

-- Juntar los datos por tiempo no mas de 5 minutos
DatosFinal = FOREACH DatosLine {
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
        COUNT(Ordenado) AS count;
};
DESCRIBE DatosFinal;
D = LIMIT DatosFinal 10;
DUMP D;