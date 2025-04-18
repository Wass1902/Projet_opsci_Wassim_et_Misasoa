echo "🔄 Reconstruction et démarrage des conteneurs..."
docker compose down
docker compose rm -f
docker compose up --build -d

