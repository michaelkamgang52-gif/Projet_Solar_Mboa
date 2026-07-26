#  Livrable : Documentation du Schéma en Étoile (BigQuery)

### 1. Granularité de la Table de Faits
*   **Table** : `fact_energy_production`
*   **Définition** : 1 ligne représente 1 capture de télémétrie émise par un panneau toutes les 15 minutes.

### 2. Dictionnaire des Dimensions & Cardinalités Estimées

| Nom de la Dimension | Clé de Jointure (PK) | Cardinalité Estimée | Justification Métier |
| :--- | :--- | :--- | :--- |
| `dim_time` | `time_key` | ~35 040 lignes / an | Granularité de 15 min (4 mesures × 24h × 365j). |
| `dim_installation` | `installation_key` | 5 285 lignes | Équivalent au nombre exact de capteurs actifs de SolarMboa. |
| `dim_client` | `client_key` | ~5 000 lignes | Nombre total de foyers abonnés aux services électriques. |
| `dim_region` | `region_key` | 10 à 50 lignes | Régions administratives couvertes par le réseau de distribution. |
| `dim_tariff_plan` | `tariff_key` | < 10 lignes | Nombre restreint d'offres commerciales (PAYG, Post-payé, etc.). |