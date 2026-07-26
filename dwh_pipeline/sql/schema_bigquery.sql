-- ==============================================================================
-- 1. CRÉATION DES TABLES DE DIMENSIONS (SÉCURISÉES AVEC CLÉS ET TYPES PROPRES)
-- ==============================================================================

-- Dimension Temps (Granularité horaire/journalière)
CREATE OR REPLACE TABLE `solarmboa_dwh.dim_time` (
    time_key STRING OPTIONS(description="Clé primaire générée au format YYYYMMDDHHMM"),
    full_date DATE,
    year INT64,
    month INT64,
    day INT64,
    hour INT64,
    minute INT64
);

-- Dimension Région
CREATE OR REPLACE TABLE `solarmboa_dwh.dim_region` (
    region_key STRING OPTIONS(description="Code ISO ou ID unique de la région"),
    region_name STRING,
    country STRING
);

-- Dimension Plan Tarifaire
CREATE OR REPLACE TABLE `solarmboa_dwh.dim_tariff_plan` (
    tariff_key STRING OPTIONS(description="ID du forfait (ex: PAYG_Premium, Basic)"),
    plan_name STRING,
    cost_per_kwh NUMERIC
);

-- Dimension Client
CREATE OR REPLACE TABLE `solarmboa_dwh.dim_client` (
    client_key STRING OPTIONS(description="ID unique du client SolarMboa"),
    full_name STRING,
    account_status STRING,
    creation_date DATE
);

-- Dimension Installation (Kits solaires)
CREATE OR REPLACE TABLE `solarmboa_dwh.dim_installation` (
    installation_key STRING OPTIONS(description="ID unique du kit matériel"),
    client_key STRING,
    sensor_model STRING,
    capacity_w INT64,
    install_date DATE
);

-- ==============================================================================
-- 2. CRÉATION DE LA TABLE DE FAITS CENTRALE (OPTIMISÉE POUR BIGQUERY)
-- ==============================================================================

CREATE OR REPLACE TABLE `solarmboa_dwh.fact_energy_production` (
    fact_id STRING OPTIONS(description="UUID unique de la ligne de mesure"),
    -- Clés de jointure vers les dimensions (Foreign Keys)
    installation_key STRING,
    client_key STRING,
    region_key STRING,
    tariff_key STRING,
    time_key STRING,
    -- Métriques de performance (Granularité : 1 mesure / capteur / 15 min)
    solar_output_w FLOAT64,
    battery_level_pct FLOAT64,
    consumption_w FLOAT64
)
-- Optimisation FinOps BigQuery pour accélérer les requêtes Looker et réduire les coûts
PARTITION BY DATE(time_key)
CLUSTER BY region_key, installation_key;
