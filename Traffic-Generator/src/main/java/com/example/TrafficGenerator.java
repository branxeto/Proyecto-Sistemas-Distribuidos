package com.example;

import java.util.ArrayList;
import java.util.List;
import java.util.Random;

import org.bson.Document;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.mongodb.client.FindIterable;
import com.mongodb.client.MongoClient;
import com.mongodb.client.MongoClients;
import com.mongodb.client.MongoCollection;
import com.mongodb.client.MongoDatabase;
import static com.mongodb.client.model.Filters.eq;

public class TrafficGenerator {
    private static final Random random = new Random();
    
    // Parámetros
    private static final String DISTRIBUCION = "poisson"; // "poisson" o "uniforme"
    private static final double LAMBDA_POISSON = 5.0; // eventos por segundo
    private static final double INTERVALO_UNIFORME_MIN = 10000; // 100 milisegundos
    private static final double INTERVALO_UNIFORME_MAX = 50000; // 500 milisegundos

    public static void main(String[] args) {
        ObjectMapper mapper = new ObjectMapper();
        // Conexión a MongoDB
        String uri = "mongodb+srv://Branco:Branco1323@universidad.wavnkf6.mongodb.net/?retryWrites=true&w=majority&appName=Universidad";
        try (MongoClient mongoClient = MongoClients.create(uri)) {
            MongoDatabase database = mongoClient.getDatabase("Sistemas_Distribuidos");
            MongoCollection<Document> collection = database.getCollection("Datos");
            
            // Cargar todos los datos para generar las consultas.
            Document valores = collection.find(eq("_id","1")).first();
            Consultas consulta = null;// Conseguir una lista de Documentos (Todos los documentos)
            List<Double> speedList = new ArrayList<>();
            List<Integer> levelList = new ArrayList<>();
            List<Integer> severityList = new ArrayList<>();
            List<String> streetList = new ArrayList<>();
            List<String> cityList = new ArrayList<>();            
            List<Double> speedKMHList = new ArrayList<>();
        
            try {
                if(valores != null){
                    consulta = mapper.readValue(valores.toJson(), Consultas.class);
                    speedList = consulta.getSpeed();
                    levelList = consulta.getLevel();
                    severityList = consulta.getSeverity();
                    streetList = consulta.getStreet();
                    cityList = consulta.getCity();
                    speedKMHList = consulta.getSpeedKMH();
                } else {
                    System.err.println("No se encontraron valores en la base de datos (variable valores)");
                }
            } catch (JsonProcessingException e) {
                System.err.println(e);
            }

            //<----- Generador de tráficos ----->
            
            while (true) {
                // Empezamos a medir el tiempo de la consulta (INICIO)
                long startTime = System.currentTimeMillis();
                //<------ Generador de consultas ------>
                int tipoConsulta = random.nextInt(6);
                switch (tipoConsulta) {
                    case 1:
                    {
                        FindIterable<Document> iterable = collection.find(eq("jams.level",levelList.get(random.nextInt(levelList.size()))));
                        List<Document> request = new ArrayList<>();
                        iterable.into(request);
                        break;
                    }
                    case 2:
                    {
                        FindIterable<Document> iterable = collection.find(eq("jams.speed",speedList.get(random.nextInt(speedList.size()))));
                        List<Document> request = new ArrayList<>();
                        iterable.into(request);
                        break;
                    }
                    case 3:
                    {
                        FindIterable<Document> iterable = collection.find(eq("jams.severity",severityList.get(random.nextInt(severityList.size()))));
                        List<Document> request = new ArrayList<>();
                        iterable.into(request);
                        break;
                    }
                    case 4:
                    {
                        FindIterable<Document> iterable = collection.find(eq("jams.street",streetList.get(random.nextInt(streetList.size()))));
                        List<Document> request = new ArrayList<>();
                        iterable.into(request);
                        break;
                    }
                    case 5:
                    {
                        FindIterable<Document> iterable = collection.find(eq("jams.city",cityList.get(random.nextInt(cityList.size()))));
                        List<Document> request = new ArrayList<>();
                        iterable.into(request);
                        break;
                    }
                    case 6:
                    {
                        FindIterable<Document> iterable = collection.find(eq("jams.speedKMH",speedKMHList.get(random.nextInt(speedKMHList.size()))));
                        List<Document> request = new ArrayList<>();
                        iterable.into(request);
                        break;
                    }
                    default:
                        throw new AssertionError();
                }


                
                // Finalizamos la medición del tiempo (FINAL)
                long endTime = System.currentTimeMillis();
                System.out.println("Tiempo de consulta (ms): " + (endTime - startTime));

                // Esperar según distribución
                long tiempoEspera = calcularTiempoEspera();
                try {
                    Thread.sleep(tiempoEspera);
                } catch (InterruptedException e) {
                    System.err.println(e);
                }
            }
            
        }
    }

    private static long calcularTiempoEspera() {
        if (DISTRIBUCION.equals("poisson")) {
            double tiempo = Math.log(1 - random.nextDouble()) / (-LAMBDA_POISSON);
            return (long) (tiempo * 1000); // de segundos a milisegundos
        } else if (DISTRIBUCION.equals("uniforme")) {
            return (long) (INTERVALO_UNIFORME_MIN + (INTERVALO_UNIFORME_MAX - INTERVALO_UNIFORME_MIN) * random.nextDouble());
        } else {
            return 500; // valor por defecto
        }
    }
}
