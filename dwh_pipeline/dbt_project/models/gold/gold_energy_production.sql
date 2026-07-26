-- Modèle dbt couche Gold : Agrégats de performance prêts pour la BI
{{ config(materialized='table') }}

SELECT 
    region_name,
    DATE(event_timestamp) as production_date,
    COUNT(DISTINCT sensor_id) as total_active_sensors,
    AVG(solar_output_w) as avg_solar_output_w,
    AVG(consumption_w) as avg_consumption_w,
    MIN(battery_level_pct) as critical_battery_level
FROM {{ ref('int_telemetry_cleaned') }}
GROUP BY region_name, production_date