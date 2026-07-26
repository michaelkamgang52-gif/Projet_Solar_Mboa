-- Modèle dbt couche Bronze : Recopie brute de la télémétrie issue de GCS
{{ config(materialized='view') }}

SELECT 
    sensor_id,
    installation_id,
    timestamp,
    solar_output_w,
    battery_level_pct,
    consumption_w,
    alert_code,
    region
FROM {{ source('solarmboa_raw', 'sensors_telemetry') }}
