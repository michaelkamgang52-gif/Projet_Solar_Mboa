# 📉 Livrable 5 : Rapport d'Audit FinOps (Optimisation Staging)

### 1. Diagnostic des 3 sources de gaspillage (Total actuel : 3 800 $/mois)
1.  **Cluster GKE en exécution 24h/24 (60% de la facture)** : L'environnement de test de nuit utilise des serveurs qui restent allumés en journée pour rien.
2.  **Rétention infinie du stockage Standard (25% de la facture)** : Des téraoctets de données brutes IoT de staging datant de plusieurs mois sont stockés au prix fort sans politique d'archivage.
3.  **Surdimensionnement des bases NoSQL (15% de la facture)** : Cassandra et MongoDB sont provisionnés sur des machines de niveau Production (Multi-zones) pour de simples tests d'intégration.

### 2. Plan de réduction des coûts (Objectif : Économie de 65%)
*   **Action 1 (GKE)** : Implémentation de scripts d'arrêt automatique du cluster de staging à 18h et réactivation à 08h. (Économie : -40%).
*   **Action 2 (GCS)** : Activation d'une règle de cycle de vie supprimant définitivement toutes les données de staging vieilles de plus de 14 jours. (Économie : -15%).
*   **Action 3 (Bases)** : Passage des conteneurs NoSQL sur des instances GCP de type `e2-medium` monozone. (Économie : -10%).

**Nouveau coût estimé après optimisation : 1 330 $/mois (Soit 65% d'économie globale).**