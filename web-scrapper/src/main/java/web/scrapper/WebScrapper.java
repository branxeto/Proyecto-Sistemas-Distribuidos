package web.scrapper;

import java.io.IOException;
import java.net.URI;
import java.net.URISyntaxException;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;

import org.bson.Document;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.ArrayNode;
import com.fasterxml.jackson.databind.node.ObjectNode;
import com.mongodb.client.MongoClient;
import com.mongodb.client.MongoClients;
import com.mongodb.client.MongoCollection;
import com.mongodb.client.MongoDatabase;
import com.mongodb.client.result.InsertOneResult;

public class WebScrapper {
    public static void main(String[] args) throws Exception {
        // <--- Crear objeto con valores para generador de trafico --->
        ObjectMapper mapper = new ObjectMapper();
        ArrayNode SpeedKMH = mapper.createArrayNode();
        ArrayNode level = mapper.createArrayNode();
        ArrayNode severity = mapper.createArrayNode();
        ArrayNode street = mapper.createArrayNode();
        ArrayNode city = mapper.createArrayNode();
        ArrayNode speed = mapper.createArrayNode();
        
        // <--- HILO --->
        ScheduledExecutorService scheduler = Executors.newSingleThreadScheduledExecutor();
        scheduler.scheduleAtFixedRate(() -> {
            try {
                ejecutarTarea(SpeedKMH, level, severity, street, city, speed);
            } catch (Exception e) {
                System.err.println("Error al ejecutar la tarea: " + e.getMessage());
            }
        }, 0, 5, TimeUnit.MINUTES);
    }

    public static void ejecutarTarea(ArrayNode SpeedKMH, ArrayNode level, ArrayNode severity, ArrayNode street, ArrayNode city, ArrayNode speed) throws Exception {
        String json = ""; //Aqui se va a guardar el JSON crudo
        ObjectMapper objectMapper = new ObjectMapper();

        // <--- CONSULTA HTTP --->
        try {
            //Construir Request
            HttpRequest request = HttpRequest.newBuilder()
                .uri(new URI("https://www.waze.com/live-map/api/georss?top=-32.9167&bottom=-34.3167&left=-71.7167&right=-69.7833&env=row&types=alerts,traffic"))
                .GET()
                .header("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/132.0.0.0 Safari/537.36 OPR/117.0.0.0")
                .build();

            // Enviar y recibir respuesta que el cliente mando (Request)
            HttpResponse<String> response = HttpClient.newHttpClient()
                .send(request, HttpResponse.BodyHandlers.ofString());
            json = response.body(); 

            //System.out.println(json);
        } catch (IOException e) {
            throw new RuntimeException(e);
        } catch (URISyntaxException | InterruptedException e) {
            System.err.println(e);
        }

        // <--- MANEJAR FORMATO JSON --->
        Evento evento = objectMapper.readValue(json, Evento.class); // Variable para procesar la informacion
        List<ObjectNode> eventos = new ArrayList<>(); // Lista para guardar los eventos

        for (JsonNode i : evento.getJams()) {
            ObjectNode EventoFinal = objectMapper.createObjectNode(); // Variable para guardar el JSON final
            EventoFinal.put("endTimeMillis", evento.getEndTimeMillis());
            EventoFinal.put("startTimeMillis", evento.getStartTimeMillis());
            EventoFinal.put("startTime", evento.getStartTime());
            EventoFinal.put("endTime", evento.getEndTime());
            EventoFinal.set("jams", i);
            eventos.add(EventoFinal); // Agregar el evento a lista

            boolean contains = false;

            Double speedValue = i.get("speed").asDouble();
            for(JsonNode j : SpeedKMH){
                if(speedValue == j.asDouble()){
                    contains = true;
                    break;
                }
            }
            if(!contains){
                speed.add(speedValue);
            }
            
            contains = false;
            int levelValue = i.get("level").asInt();
            for(JsonNode j : level){
                if(levelValue == j.asInt()){
                    contains = true;
                    break;
                }
            }
            if(!contains){
                level.add(levelValue);
            }

            contains = false;
            int severityValue = i.get("severity").asInt();
            for (JsonNode j : severity){
                if(severityValue == j.asInt()){
                    contains = true;
                    break;
                }
            }
            if(!contains){
                severity.add(severityValue);
            }

            contains = false;
            String streetValue = i.get("street").asText();
            for (JsonNode j : street){
                if(streetValue.equals(j.asText())){
                    contains = true;
                    break;
                }
            }
            if(!contains){
                street.add(streetValue);
            }

            contains = false;
            String cityValue = i.get("city").asText();
            for (JsonNode j : city){
                if(cityValue.equals(j.asText())){
                    contains = true;
                    break;
                }
            }
            if(!contains){
                city.add(cityValue);
            }

            contains = false;
            Double speedKMH = i.get("speedKMH").asDouble();
            for (JsonNode j : SpeedKMH){
                if(speedKMH == j.asDouble()){
                    contains = true;
                    break;
                }
            }
            if(!contains){

                SpeedKMH.add(speedKMH);
            }
        }
        //System.out.println("Evento: " + eventoString);

        // <--- Base de Datos --->
        String uri = "mongodb+srv://Branco:Branco1323@universidad.wavnkf6.mongodb.net/?retryWrites=true&w=majority&appName=Universidad";
        try (MongoClient mongoClient = MongoClients.create(uri)) {
            MongoDatabase database = mongoClient.getDatabase("Sistemas_Distribuidos");
            MongoCollection<Document> collection = database.getCollection("Datos");
            for(ObjectNode i: eventos){
                String eventoString = objectMapper.writeValueAsString(i);
                //System.out.println("Evento: " + eventoString);
                Document doc = Document.parse(eventoString); 
                if (doc != null) {
                    InsertOneResult result = collection.insertOne(doc);
                    System.out.println("Documento insertado con ID: " + result.getInsertedId());
                } else {
                    System.out.println("Hubo un error en la obtención del JSON.");
                }
            }
        }
    }
}
