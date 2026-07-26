-- Modèle dbt couche Silver : Nettoyage et normalisation des timestamps
{{ config(materialized='table') }}

WITH deduplicated AS (
    SELECT *,
        ROW_NUMBER() OVER(PARTITION BY sensor_id, timestamp ORDER BY timestamp DESC) as rn
    FROM {{ ref('stg_telemetry') }}
)
SELECT 
    sensor_id,
    installation_id,
    -- Normalisation du format de date mixte
    SAFE_CAST(timestamp AS TIMESTAMP) as event_timestamp,
    SAFE_CAST(solar_output_w AS FLOAT64) as solar_output_w,
    SAFE_CAST(battery_level_pct AS FLOAT64) as battery_level_pct,
    SAFE_CAST(consumption_w AS FLOAT64) as consumption_w,
    COALESCE(alert_code, 'NOMINAL') as alert_code,
    UPPER(region) as region_name
FROM deduplicated
WHERE rn = 1 -- Suppression des doublons
  AND battery_level_pct BETWEEN 0 AND 100 -- Nettoyage des valeurs aberrantes
