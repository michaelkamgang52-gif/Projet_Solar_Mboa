#  Livrable 3 : Arbitrage Compute & Serverless

### 1. Ingestion IoT Temps Réel (5 285 capteurs)
*   **Choix** : **Cloud Run**
*   **Justification** : Flux continu mais variable. Cloud Run offre une scalabilité automatique instantanée à la seconde près. GKE serait surdimensionné (frais de gestion de cluster inutiles) et Cloud Functions risquerait des surcoûts liés au nombre d'exécutions individuelles (12M/jour).
*   **Coût estimé** : 80 $/mois.

### 2. Traitement Batch Nocturne (dbt Core / Delta Lake)
*   **Choix** : **GKE (Google Kubernetes Engine) - Autopilot**
*   **Justification** : Les calculs de jointures massives sur l'historique nécessitent de la puissance brute stable (CPU/RAM dédiés) pendant plusieurs dizaines de minutes. Les limites de temps de Cloud Run (60 min) et Cloud Functions (60 min) sont trop risquées pour des batchs extensibles.
*   **Coût estimé** : 150 $/mois (Facturé uniquement durant l'exécution de nuit).

### 3. API de Facturation & Dashboards Looker
*   **Choix** : **Cloud Functions**
*   **Justification** : Requêtes asynchrones et intermittentes (uniquement quand un client demande sa facture ou qu'un manager consulte Looker). Le modèle du "Passage à zéro" (0 execution = 0 dollar) est parfait ici.
*   **Coût estimé** : 15 $/mois.