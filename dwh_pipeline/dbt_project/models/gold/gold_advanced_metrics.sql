{{ config(materialized='table') }}

WITH telemetry_stats AS (
    SELECT 
        installation_id, region_name,
        (COUNT(event_timestamp) / 96.0) * 100 AS uptime_pct, -- 96 mesures par jour
        COUNT(CASE WHEN alert_code != 'NOMINAL' THEN 1 END) / COUNT(*) AS anomaly_rate
    FROM {{ ref('int_telemetry_cleaned') }}
    GROUP BY installation_id, region_name
),
financial_stats AS (
    SELECT 
        region,
        SUM(CASE WHEN payment_status = 'PAID' THEN amount ELSE 0 END) AS ca_recouvre,
        SUM(amount) AS ca_facture
    FROM {{ source('solarmboa_raw', 'payments') }}
    GROUP BY region
)
SELECT 
    t.region_name,
    AVG(t.uptime_pct) AS avg_installation_uptime_pct,
    AVG(t.anomaly_rate) * 100 AS sensor_anomaly_rate_pct,
    f.ca_recouvre, f.ca_facture,
    (f.ca_recouvre / f.ca_facture) * 100 AS financial_recovery_rate_pct
FROM telemetry_stats t
JOIN financial_stats f ON t.region_name = UPPER(f.region)
GROUP BY t.region_name, f.ca_recouvre, f.ca_facture