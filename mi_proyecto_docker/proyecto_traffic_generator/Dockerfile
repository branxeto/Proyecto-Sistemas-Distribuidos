# Usar OpenJDK 21 como imagen base
FROM openjdk:21-jdk-slim

# Instalar Maven
RUN apt-get update && apt-get install -y \
    maven \
    && rm -rf /var/lib/apt/lists/*

# Establecer el directorio de trabajo
WORKDIR /app

# Copiar el archivo pom.xml y las dependencias
COPY pom.xml /app/

# Descargar las dependencias de Maven
RUN mvn dependency:go-offline

# Copiar el código fuente
COPY src /app/src/

# Construir el proyecto y generar el archivo JAR
RUN mvn clean package

# Exponer el puerto (si es necesario)
EXPOSE 8080

# Comando para ejecutar el archivo JAR
CMD ["java", "-jar", "target/proyecto_traffic_generator-1.0-SNAPSHOT.jar"]
