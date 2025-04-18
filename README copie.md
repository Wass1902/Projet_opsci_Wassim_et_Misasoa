## Projet OPSCI : Infrastructure complète avec objets connectés et architecture événementielle

### Membres du groupe
- **Wassim BOUZIDI** - 28705877
- **Misasoa ROBISON** - 21203820

## Objectif du projet
Construire une architecture complète, du déploiement à la mise en place, incluant Strapi, React, Kafka, des objets connectés et une communication via une architecture événementielle.

## Arborescence du dépôt Git

```
.
├── backend/                    # Code source Strapi
|   └──Dockerfile               # Image personnalisée pour Strapi
├── opsci-strapi-frontend/      # Frontend React
├── data/                       # Fichiers CSV (products, events, stocks)
├── docker-compose.yml          # Configuration des services Docker                  
├── scripts/                    # Scripts de gestion de l’infrastructure
│   ├── start.sh
│   └── stop.sh
└── README.md                   # Ce fichier
```


## 1. Mise en place de l’infrastructure

### Création de l’application Strapi
```bash
yarn create strapi-app backend --quickstart
```

### Dockerfile pour Strapi (backend/Dockerfile)
Inclut `corepack`, `yarn@4.9.1`, suppression de `sharp`, etc.

### Fichier `.env` (backend/.env)
Configurer les variables de connexion à PostgreSQL, ainsi que le token API Strapi, les secrets, etc.

### Fichier `docker-compose.yml`
Contient :
- **PostgreSQL** (port exposé en `5434`)
- **Strapi** (port exposé en `1337`, connecté à PostgreSQL)
- **Kafka + Zookeeper**
- **Producers / Consumers Kafka** (topics: product, stock, event, error)


## 2. Scripts de gestion

### `scripts/start.sh`
```bash
#!/bin/bash
echo "🔄 Déploiement des services..."
docker compose down
docker compose rm -f
docker compose up --build -d
```

### `scripts/stop.sh`
```bash
#!/bin/bash
echo "⏹️ Arrêt des services..."
docker compose down
```

## 3. Frontend React

### À partir du repo : [opsci-strapi-frontend](https://github.com/arthurescriou/opsci-strapi-frontend)

- Modifier `conf.ts` avec le `TOKEN` (Strapi Admin) et l'`URL`
- Lancer avec `yarn dev`

## 4. Configuration de Strapi

### Collections créées :
- `product` avec : `name`, `description`, `stock_available`, `barcode`, `product_status (enum)`
- `event` avec : `value`, `metadata (JSON)`

> ⚠️ `status` étant un mot réservé, nous avons utilisé `product_status`

## 5. Kafka + Producers/Consumers

- **Topics** créés : `product`, `event`, `stock`, `error`
- **Fichiers CSV** placés dans le dossier `data/`
- **Volumes mappés** dans le docker-compose

> Extrait docker-compose pour un producer :
```yaml
product-producer:
  image: arthurescriou/product-producer:1.0.0
  volumes:
    - ./data/products.csv:/products.csv
  environment:
    BROKER_1: kafka:9092
    BROKER_2: kafka:9092
    BROKER_3: kafka:9092
    STRAPI_URL: http://strapi:1337
    STRAPI_TOKEN: 831522c361a9f1263eb52311cb7e0112de7b5b07f2f980f1acf7beab0e0bf83b353f12b1e678ca56eb834894b4418cbb13af1f241c07648cff1e9b61e3f286734547a138f390f6d87f473b310d5c3ed61f0e83909ef9b59aa13ab7b929eea685e673df108c98533a92ea239b0ed6cfe2868cef6a95daebaeb333bb94836b10f2
    TOPIC: product
    FILE_NAME: products.csv
```

> Extrait docker-compose pour un consumer :
```yaml
  product-consumer:
    image: arthurescriou/stock-consumer:1.0.2
    environment:
      BROKER_1: kafka:9092
      BROKER_2: kafka:9092
      BROKER_3: kafka:9092
      STRAPI_TOKEN: 831522c361a9f1263eb52311cb7e0112de7b5b07f2f980f1acf7beab0e0bf83b353f12b1e678ca56eb834894b4418cbb13af1f241c07648cff1e9b61e3f286734547a138f390f6d87f473b310d5c3ed61f0e83909ef9b59aa13ab7b929eea685e673df108c98533a92ea239b0ed6cfe2868cef6a95daebaeb333bb94836b10f2
      STRAPI_URL: http://strapi:1337
      TOPIC: product
    depends_on:
      - kafka
      - strapi
    networks:
      - kafka_net
      - strapi-net
```

## 6. Mise à jour d’un produit via Kafka

- Modifier ou créer un nouveau `products.csv` avec un `barcode` déjà existant pour modifier et un nouveau `barcode` pour la création
- Kafka mettra automatiquement à jour l’entrée correspondante dans Strapi
- Exemple :
```csv
name,description,stock_available,barcode,product_status
Bananes,Banane mûres,50,1234567890123,safe
```

## 7. Utilisation

```bash
# Arrêt des services
./scripts/stop.sh

# Lancement complet
./scripts/start.sh

# Relancer un producer manuellement (si modif du fichier CSV)
docker compose restart product-producer
```


## 8. Accès rapides
- **Strapi Admin** : http://localhost:1337/admin
- **Frontend React** : http://localhost:5173

## 9. Vidéo de démonstration
Une vidéo est disponible et présente les différentes étapes de déploiement, de communication entre les services, ainsi que le rendu frontend final. Vous la retrouverez [sur ce lien](https://drive.google.com/file/d/1pMmqdXZuXormdh6Bj4j1LG0t_pcH3Ir1/view?usp=share_link) (nous vous conseillons de télécharger la vidéo pour une résolution optimale).
