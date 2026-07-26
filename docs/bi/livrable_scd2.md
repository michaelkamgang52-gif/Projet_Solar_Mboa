#  Livrable : Modélisation Avancée Slowly Changing Dimension (SCD) Type 2

Pour suivre l'évolution des équipements au fil du temps (changement de forfait, remplacement de panneau) sans écraser le passé, la dimension `dim_installation` applique les règles strictes du SCD Type 2 exigées par la direction.

### 1. Structure de la Table `dim_installation_scd2` (BigQuery)

| Nom de la Colonne | Type | Rôle dans le SCD Type 2 |
| :--- | :--- | :--- |
| `installation_surrogate_key` | STRING | Clé artificielle unique (Hash généré par dbt pour chaque version). |
| `installation_id` | STRING | Clé naturelle de l'équipement. |
| `sensor_model` | STRING | Modèle du capteur sujet au changement. |
| `capacity_w` | INT64 | Puissance du panneau. |
| `effective_date` | TIMESTAMP | Date de début de validité de cette configuration. |
| `expiry_date` | TIMESTAMP | Date de fin de validité (vaut `NULL` si la ligne est active). |
| `is_current` | BOOLEAN | Indicateur d'activité (`TRUE` = version actuelle, `FALSE` = historique). |

### 2. Exemple de cycle de vie (Scénario Métier)
Si l'installation `INST-77` passe d'une puissance de 150W à 300W le 15 Juillet 2026 :
*   **Ligne historique** : `capacity_w` = 150, `effective_date` = "2026-01-01", `expiry_date` = "2026-07-15", `is_current` = FALSE
*   **Ligne active** : `capacity_w` = 300, `effective_date` = "2026-07-15", `expiry_date` = NULL, `is_current` = TRUE

### 3. Code SQL de génération d'instantané (Fichier dbt Snapshot)
```sql
{% snapshot snapshot_installations %}
{{
    config(
      target_database='solarmboa-technologies',
      target_schema='solarmboa_snapshots',
      unique_key='installation_id',
      strategy='check',
      check_cols=['sensor_model', 'capacity_w'],
    )
}}
SELECT 
    installation_id, sensor_model, capacity_w,
    valid_from AS effective_date, valid_to AS expiry_date, is_current
FROM {{ source('solarmboa_raw', 'installations') }}
{% endsnapshot %}
```