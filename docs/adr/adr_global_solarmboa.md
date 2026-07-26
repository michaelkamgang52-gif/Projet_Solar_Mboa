#  Architecture Decision Records (ADR) - SolarMboa Technologies

Ce document fait office de livrable de référence décrivant les choix technologiques et structurels retenus pour la refonte globale de la plateforme de données.

---

## ADR-01 : Persistance Polyglotte (Multi-NoSQL local)
*   **Contexte** : SolarMboa doit ingérer 12 millions d'événements de télémétrie par jour, gérer des profils d'installations à schéma variable, cartographier son réseau de techniciens et mettre en cache des compteurs.
*   **Décision** : Rejet d'un SGBDR classique au profit d'une architecture multi-NoSQL intégrée par Docker.
    *   *MongoDB* : Choisi pour la flexibilité des profils clients au format JSON.
    *   *Redis* : Choisi comme cache en mémoire (latence < 1ms) pour vérifier le statut des recharges en temps réel.
    *   *Cassandra / InfluxDB* : Choisis pour la haute disponibilité (modèle AP) de l'ingestion chronologique.
    *   *Neo4j* : Choisi pour le suivi des relations métiers complexes et la détection des fraudes de connexion.

---

## ADR-02 : Infrastructure Cloud GCP & Isolation Réseau (Security by Design)
*   **Contexte** : Sécurisation absolue des flux et conformité FinOps.
*   **Décision** : Déploiement automatisé par Terraform sur Google Cloud Platform (GCP).
    *   Création de deux VPC étanches (`Staging` et `Prod`) pour éliminer toute fuite de données de test.
    *   Désactivation totale des IP publiques. Usage exclusif de Cloud NAT et de passerelles d'API restrictives (port 443 unique).
    *   Interdiction des rôles primitifs `Owner`/`Editor`. Matrice IAM basée uniquement sur le moindre privilège avec des comptes de services spécialisés par couche applicative.

---

## ADR-03 : Consolidation Data Warehouse & Stockage Transactionnel ACID
*   **Contexte** : Garantir la consistance des calculs face aux pannes et optimiser les coûts analytiques.
*   **Décision** : Implémentation d'une couche Lakehouse combinant Delta Lake et BigQuery.
    *   *Delta Lake* : Utilisé pour sécuriser les écritures brutes (Bronze) sur GCS grâce à son journal de transactions (`_delta_log`), protégeant le système contre les écritures partielles en cas de coupure (Rollback automatique validé).
    *   *BigQuery (Schéma en Étoile)* : Table de faits centrale `fact_energy_production` partitionnée par jour et clusterisée par région pour restreindre les volumes scannés (économie FinOps de 97.5% démontrée sous EXPLAIN).

---

## ADR-04 : Pipeline de Transformation et Observabilité dbt Core
*   **Contexte** : Nettoyage automatique des dates hétérogènes et monitoring des délais d'ingestion.
*   **Décision** : Orchestration en couches via dbt Core (Bronze ➔ Silver ➔ Gold).
    *   Mise en place de tests de qualité automatisés (`not_null`, `accepted_values`).
    *   Déploiement d'un test de fraîcheur dbt configuré à un seuil critique de **2 heures** maximum pour déclencher des alertes automatiques en cas de rupture de flux.
    *   Calcul centralisé des KPIs (Uptime des installations, Chiffre d'Affaires recouvré vs facturé).
