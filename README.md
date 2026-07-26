# ☀️ Plateforme Data & IA Engineering — SolarMboa Technologies

Bienvenue sur le dépôt officiel de la plateforme de données modernisée de **SolarMboa Technologies**, startup solaire camerounaise en pleine expansion. Ce projet valide l'infrastructure d'ingestion IoT massive (12 millions d'événements/jour), le déploiement Cloud automatisé, l'architecture Lakehouse transactionnelle et la gouvernance décisionnelle de l'entreprise.

---

##  1. Arborescence Réelle du Projet & Traces Git

L'organisation des fichiers respecte scrupuleusement les standards de l'ingénierie de données :

```text
Projet_Solar_Mboa/
├──  cloud/
│   └──  terraform/
│       └──  main.tf                  # Automatisation réseau GCP & Buckets GCS
├──  data/
│   ├──  delta_lake_bronze/           # Table transactionnelle ACID Delta Lake
│   └──  sensors_telemetry.csv        # Données brutes des 5 285 capteurs IoT
├──  dwh_pipeline/
│   ├──  dbt_project/
│   │   └──  models/
│   │       ├──  bronze/              # stg_telemetry.sql (Vue brute)
│   │       ├──  ilver/              # int_telemetry_cleaned.sql (Nettoyage & Déduplication)
│   │       ├──  gold/                # gold_energy_production.sql & gold_advanced_metrics.sql
│   │       └──  schema.yml           # Tests de qualité et observabilité (Freshness 2h)
│   ├──  sql/
│   │   └──  schema_bigquery.sql      # DDL du Schéma en Étoile (Faits et 5 Dimensions)
│   └──  ingest_delta_acid.py         # Pipeline Python transactionnel avec preuve de Rollback
├──  scripts/
│   ├──  import_mongo.py              # Ingestion des 4 800 profils clients JSON
│   ├──  import_redis.py              # Cache des alertes des 5 285 capteurs
│   ├──  import_influx.py             # Séries temporelles asynchrones nettes de valeurs NaN
│   └──  import_cassandra.py          # Ingestion de masse historique (Timeout 60s)
├──  docs/
│   ├──  cloud/                       # Livrables réseau, IAM, Compute et Audit FinOps
│   ├──  dwh/                         # Cardinalités du DWH et Catalogue de données Gold
│   ├──  bi/                          # Spécifications du dashboard Looker et dbt SCD Type 2
│   └──  adr/
│       └──  adr_global_solarmboa.md  # Architecture Decision Records (Livrable de synthèse)
├──  docker-compose.yml               # Orchestration des 5 conteneurs NoSQL
└──  README.md                        # Guide de référence général du projet
```

---

##  2. Registre Central des Connexions & Identifiants Personnels

Toutes les bases NoSQL de la stack locale sont sécurisées à votre nom avec les accès définis dans le `docker-compose.yml` :

| Technologie NoSQL | Rôle Métier | URL / Port Local | Identifiant (User) | Mot de passe (Password) |
| :--- | :--- | :--- | :--- | :--- |
| **MongoDB** | Profils clients & Contrats | `localhost:27017` | `michaelkamgang` | `michaelkamgang52` |
| **Neo4j** | Graphe réseau distribution | `localhost:7474` (Web)<br>`bolt://localhost:7687` | `neo4j` | `michaelkamgang52` |
| **InfluxDB** | Métriques IoT Temps Réel | `localhost:8086` | `michaelkamgang` | `michaelkamgang52` |
| **Cassandra** | Historique long terme | `localhost:9042` | *Anonyme local* | *Aucun (Timeout 60s)* |
| **Redis** | Cache d'alertes instantané | `localhost:6379` | *Anonyme local* | *Aucun* |

*   **URI de connexion MongoDB (VS Code / Compass)** : `mongodb://michaelkamgang:michaelkamgang52@localhost:27017/`
*   **Token Admin InfluxDB (Python API)** : `solarmboa_secret_token_2026_test` (`Org: solarmboa_org` / `Bucket: telemetry_bucket`)

---

## 🏗️ 3. Schéma Architectural de la Plateforme End-to-End

```text
[5 285 Capteurs IoT] ──> [Fichier CSV / Ingestion NoSQL]
                              │
  ┌───────────────────────────┴──────────────────────────────────────────────────────┐
  ▼ (MongoDB / Redis)         ▼ (InfluxDB)                  ▼ (Cassandra)            ▼ (Neo4j)
[Profils & Cache]           [Séries Temporelles]         [Données de Masse]        [Graphe Réseau]
  │                           │                             │                        │
  └───────────────────────────┴──────────────┬──────────────┴────────────────────────┘
                                             ▼
                               [Data Lakehouse Pipeline]
                                             │
                       ┌─────────────────────┴─────────────────────┐
                       ▼ (Couche Ingestion Open Format)            ▼ (Couche Transformation)
                 [Delta Lake GCS Buckets]                     [dbt Core Framework]
                 ├── Bronze (Raw, Lifecycle 30j Nearline)     ├── Bronze : stg_telemetry
                 └── Gold (Enforced Public Access Block)      ├── Silver : int_telemetry_cleaned
                                                              └── Gold   : Métriques Métiers
                                                                           (Uptime %, CA Recouvré %)
                                                                           (Freshness Check 2h)
                                                                           (SCD Type 2)
                                                                           │
                                                                           ▼
                                                              [Data Warehouse BigQuery]
                                                              ├── Table de Faits centrale
                                                              └── 5 Dimensions (Schéma en Étoile)
                                                                           │
                                                                           ▼
                                                              [Dashboard Looker Studio]
                                                              └── 6 Visualisations Décisionnelles
```

---

## 🛠️ 4. Alignement Strict sur les Critères Techniques d'Évaluation

### A. Preuve de la robustesse ACID (Format Delta Lake)
Le pipeline Python utilise le framework natif Apache Arrow (`pyarrow`) pour injecter les lots de télémétrie dans le dossier `data/delta_lake_bronze`. Lors d'une simulation de crash réseau (coupure de courant forcée), le journal de transactions `_delta_log` invalide automatiquement l'écriture partielle corrompue et réalise un **Rollback à la Version 0 saine**, préservant ainsi l'intégrité des 500 premières lignes injectées.

### B. Optimisation FinOps & Analyse EXPLAIN (BigQuery)
La table de faits centrale `fact_energy_production` est optimisée pour l'analyse régionale de Looker Studio :
*   **Partitionnement** par `DATE(time_key)`
*   **Clustering** par `region_key` et `installation_key`
*   *Résultat de l'analyse EXPLAIN* : Le volume de données scanné passe de 7.57 Go à 185 Mo, générant une **économie budgétaire de 97.5%** sur les requêtes analytiques de la direction.

### C. Qualité et Observabilité dbt Core
Le fichier `schema.yml` orchestre deux types de tests automatisés :
1.  **Tests de Qualité** : Validation d'absence de valeurs nulles (`not_null`) sur les colonnes clés et restrictions des codes d'erreur reçus (`accepted_values: ['NOMINAL', 'ALERT_OVERHEAT', 'ALERT_LOW_BATTERY', 'ERROR_DISCONNECTED']`).
2.  **Test d'Observabilité (Freshness)** : dbt lance un avertissement si aucune nouvelle donnée de télémétrie n'a atteint le Data Warehouse depuis plus de **2 heures**, garantissant un suivi rigoureux des pannes sur le réseau camerounais.

### D. Modélisation Avancée SCD Type 2
La dimension des kits matériels `dim_installation` gère l'historisation lente à l'aide de marqueurs temporels standardisés (`effective_date`, `expiry_date`, `is_current`). Si un panneau solaire de 150W est mis à niveau vers un modèle de 300W, l'ancienne ligne est fermée en mettant à jour sa date d'expiration sans être effacée, permettant une analyse rétrospective exacte du parc à n'importe quelle date du calendrier.

---

## 🚀 5. Guide de Lancement et de Déploiement Rapide

Pour reproduire et auditer l'intégralité du projet de Michael Kamgang :

```bash
# 1. Lancer l'infrastructure NoSQL locale
docker compose up -d

# 2. Exécuter les scripts de chargement initiaux
python scripts/import_mongo.py
python scripts/import_redis.py
python scripts/import_influx.py
python scripts/import_cassandra.py
python scripts/import_neo4j.py

# 3. Tester la résilience transactionnelle ACID de Delta Lake
python dwh_pipeline/ingest_delta_acid.py
```

**Conçu, développé et documenté avec rigueur par Michael Kamgang — Ingénieur Data & IA (Juillet 2026)**
