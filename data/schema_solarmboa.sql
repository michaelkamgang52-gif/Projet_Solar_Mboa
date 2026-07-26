-- ================================================================
-- SolarMboa Technologies – Schéma de base de données transactionnelle
-- Version : 1.4  |  DHI Academy – Projet 2 – Mois 2
-- Base : MySQL 8.0
-- ================================================================

-- ----------------------------------------------------------------
-- TABLE : installations
-- Description : installations photovoltaïques actives et historiques
-- ----------------------------------------------------------------
CREATE TABLE IF NOT EXISTS installations (
    installation_id     INT PRIMARY KEY AUTO_INCREMENT,
    client_name         VARCHAR(200) NOT NULL,
    client_type         ENUM('residential','sme','health_center','school') NOT NULL,
    city                VARCHAR(100),
    region              VARCHAR(80),
    gps_lat             DECIMAL(10,6),          -- NULL pour ~8% des sites
    gps_lon             DECIMAL(10,6),
    install_date        DATE,
    tariff_plan         ENUM('Basic','Standard','Premium','Custom') DEFAULT 'Basic',
    status              ENUM('active','suspended','maintenance','churned') DEFAULT 'active',
    distributor_id      INT,
    panel_capacity_wp   INT,                    -- Watts-crête
    battery_capacity_wh INT,                    -- Watt-heures
    num_appliances      TINYINT,
    created_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_inst_dist FOREIGN KEY (distributor_id)
        REFERENCES distributors(distributor_id)
);

-- ----------------------------------------------------------------
-- TABLE : distributors
-- ----------------------------------------------------------------
CREATE TABLE IF NOT EXISTS distributors (
    distributor_id  INT PRIMARY KEY AUTO_INCREMENT,
    name            VARCHAR(200) NOT NULL,
    region          VARCHAR(80),
    contact_phone   VARCHAR(30),
    since_date      DATE,
    is_active       BOOLEAN DEFAULT TRUE
);

-- ----------------------------------------------------------------
-- TABLE : technicians
-- ----------------------------------------------------------------
CREATE TABLE IF NOT EXISTS technicians (
    technician_id   INT PRIMARY KEY AUTO_INCREMENT,
    tech_code       VARCHAR(12) UNIQUE,         -- ex: TECH-0042
    full_name       VARCHAR(200),
    region          VARCHAR(80),
    phone           VARCHAR(30),
    certified       BOOLEAN DEFAULT FALSE,
    distributor_id  INT,
    CONSTRAINT fk_tech_dist FOREIGN KEY (distributor_id)
        REFERENCES distributors(distributor_id)
);

-- ----------------------------------------------------------------
-- TABLE : sensors
-- ----------------------------------------------------------------
CREATE TABLE IF NOT EXISTS sensors (
    sensor_id       VARCHAR(20) PRIMARY KEY,    -- ex: CAM-0042-S1
    installation_id INT NOT NULL,
    sensor_type     ENUM('main','secondary') DEFAULT 'main',
    firmware_ver    VARCHAR(20),
    last_seen_at    TIMESTAMP,
    CONSTRAINT fk_sensor_inst FOREIGN KEY (installation_id)
        REFERENCES installations(installation_id)
);

-- ----------------------------------------------------------------
-- TABLE : sensor_readings
-- Note : cette table souffre de problèmes de qualité (voir audit)
--        - timestamps en formats mixtes (champ VARCHAR volontaire)
--        - battery_level_pct peut dépasser 100 (bug firmware v1.x)
--        - alert_code non standardisé (codes dupliqués en casse variable)
-- ----------------------------------------------------------------
CREATE TABLE IF NOT EXISTS sensor_readings (
    reading_id          BIGINT PRIMARY KEY AUTO_INCREMENT,
    sensor_id           VARCHAR(20),
    installation_id     INT,
    recorded_at_raw     VARCHAR(30),            -- FORMAT INCONSISTANT – à normaliser
    solar_output_w      FLOAT,                  -- NULL la nuit (normal)
    battery_level_pct   FLOAT,                  -- Anomalie : peut dépasser 100
    consumption_w       FLOAT,
    alert_code          VARCHAR(30),            -- NULL si pas d'alerte
    region              VARCHAR(40),            -- Casse et abréviations variables
    ingested_at         TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ----------------------------------------------------------------
-- TABLE : payments
-- ----------------------------------------------------------------
CREATE TABLE IF NOT EXISTS payments (
    payment_id          VARCHAR(40) PRIMARY KEY,
    installation_id     INT,
    amount_xaf          DECIMAL(12,2),          -- Négatif = remboursement
    payment_date_raw    VARCHAR(20),            -- Format inconsistant
    channel             ENUM('mtn_momo','orange_money','cash','bank_transfer'),
    status              ENUM('success','failed','pending','reversed'),
    operator_code       VARCHAR(30),            -- NULL pour cash
    created_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_pay_inst FOREIGN KEY (installation_id)
        REFERENCES installations(installation_id)
);

-- ----------------------------------------------------------------
-- TABLE : maintenance_visits
-- ----------------------------------------------------------------
CREATE TABLE IF NOT EXISTS maintenance_visits (
    visit_id            INT PRIMARY KEY AUTO_INCREMENT,
    installation_id     INT,
    technician_id       INT,
    visit_date          DATE,
    visit_type          ENUM('preventive','corrective','emergency','installation'),
    duration_min        INT,
    notes               TEXT,
    CONSTRAINT fk_visit_inst FOREIGN KEY (installation_id)
        REFERENCES installations(installation_id),
    CONSTRAINT fk_visit_tech FOREIGN KEY (technician_id)
        REFERENCES technicians(technician_id)
);

-- ================================================================
-- INDEXES RECOMMANDÉS (à analyser avec EXPLAIN)
-- ================================================================
-- CREATE INDEX idx_readings_sensor    ON sensor_readings(sensor_id);
-- CREATE INDEX idx_readings_inst      ON sensor_readings(installation_id);
-- CREATE INDEX idx_readings_region    ON sensor_readings(region);
-- CREATE INDEX idx_pay_inst_date      ON payments(installation_id, payment_date_raw);
-- CREATE INDEX idx_inst_status        ON installations(status, region);

-- ================================================================
-- PROBLÈMES CONNUS (à corriger dans l'audit SQL – Semaine 5)
-- ================================================================
-- 1. sensor_readings : ~800 doublons (même sensor_id + recorded_at_raw)
-- 2. payments : montants négatifs non filtrés (remboursements mélangés avec transactions)
-- 3. installations : ~8% sans coordonnées GPS (gps_lat/gps_lon NULL)
-- 4. sensor_readings.battery_level_pct > 100 pour ~2% des relevés (bug firmware)
-- 5. alert_code : mêmes codes présents en MAJUSCULES et minuscules
-- 6. payments : ~25 doublons (suffix -DUP) issus de double-soumission API
-- 7. sensor_readings : formats de timestamp mixtes (unix epoch, ISO, DD/MM/YYYY)
