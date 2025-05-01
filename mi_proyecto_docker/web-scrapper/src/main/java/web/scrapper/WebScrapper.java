package web.scrapper;

import java.io.IOException;
import java.net.URI;
import java.net.URISyntaxException;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.util.List;
import java.util.ArrayList;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicInteger;

import org.bson.Document;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.ArrayNode;
import com.fasterxml.jackson.databind.node.ObjectNode;
import com.mongodb.client.MongoClient;
import com.mongodb.client.MongoClients;
import com.mongodb.client.MongoCollection;
import com.mongodb.client.MongoDatabase;
import static com.mongodb.client.model.Filters.eq;
import static com.mongodb.client.model.Updates.combine;
import static com.mongodb.client.model.Updates.set;
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
        AtomicInteger contador = new AtomicInteger(0);
        
        // <--- HILO --->
        ScheduledExecutorService scheduler = Executors.newSingleThreadScheduledExecutor();
        scheduler.scheduleAtFixedRate(() -> {
            try {
                int variable = contador.incrementAndGet();
                ejecutarTarea(SpeedKMH, level, severity, street, city, speed, variable);
                if(variable == 50){
                    System.out.println("Se han alcanzado los 50 eventos.");
                    scheduler.shutdown();
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        }, 0, 5, TimeUnit.MINUTES);
    }

    public static void ejecutarTarea(ArrayNode SpeedKMH, ArrayNode level, ArrayNode severity, ArrayNode street, ArrayNode city, ArrayNode speed, int contador) throws Exception {
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
        } catch (URISyntaxException e) {
            System.err.println(e);
        } catch (InterruptedException e) {
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

        List<Double> speedList = objectMapper.convertValue(speed, new TypeReference<List<Double>>() {});
        List<Integer> levelList = objectMapper.convertValue(level, new TypeReference<List<Integer>>() {});
        List<Integer> severityList = objectMapper.convertValue(severity, new TypeReference<List<Integer>>() {});
        List<String> streetList = objectMapper.convertValue(street, new TypeReference<List<String>>() {});
        List<String> cityList = objectMapper.convertValue(city, new TypeReference<List<String>>() {});
        List<Double> speedKMHList = objectMapper.convertValue(SpeedKMH, new TypeReference<List<Double>>() {});
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
            if(contador == 50){
                collection.updateOne(
                    eq("_id", "1"),
                    combine(
                        set("level", levelList),
                        set("severity", severityList),
                        set("street", streetList),
                        set("city", cityList),
                        set("speed", speedList),
                        set("speedKMH", speedKMHList)
                    )
                );
            }
        }
    }
}
