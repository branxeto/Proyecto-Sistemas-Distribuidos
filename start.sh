# Vaciar información de carpeta resultados
sudo rm -rf resultado/*

# Build docker compose
docker compose -f docker-compose-tarea2.yml build

# Run docker compose
docker compose -f docker-compose-tarea2.yml up