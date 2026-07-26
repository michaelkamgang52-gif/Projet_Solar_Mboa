import os
import pandas as pd
from cassandra.cluster import Cluster

print("🔄 Initialisation du script Cassandra...", flush=True)

# 1. Définition du chemin des données
BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
FILE_PATH = os.path.join(BASE_DIR, "data", "sensors_telemetry.csv")

try:
    print("🔄 Connexion au cluster Cassandra Docker...", flush=True)
    cluster = Cluster(['localhost'], port=9042)
    session = cluster.connect()

    # 2. Création du Keyspace (l'équivalent de la base de données)
    print("🧱 Création du Keyspace solarmboa...", flush=True)
    session.execute("""
        CREATE KEYSPACE IF NOT EXISTS solarmboa_keyspace
        WITH replication = {'class': 'SimpleStrategy', 'replication_factor': 1};
    """)
    session.set_keyspace('solarmboa_keyspace')

    # 3. Création de la table avec une clé de partitionnement propre
    print("🧱 Création de la table telemetry...", flush=True)
    session.execute("""
        CREATE TABLE IF NOT EXISTS telemetry (
            sensor_id text,
            timestamp text,
            installation_id text,
            solar_output_w double,
            battery_level_pct double,
            consumption_w double,
            alert_code text,
            region text,
            PRIMARY KEY (region, sensor_id, timestamp)
        );
    """)

    print("📖 Lecture du fichier de télémétrie...", flush=True)
    df = pd.read_csv(FILE_PATH)
    
    # On limite à 500 lignes pour l'import local d'évaluation
    sample_df = df.head(500)

    print(f"📥 Injection de {len(sample_df)} lignes dans Cassandra...", flush=True)
    
    # Préparation de la requête pour optimiser l'insertion
    query = """
    INSERT INTO telemetry (sensor_id, timestamp, installation_id, solar_output_w, battery_level_pct, consumption_w, alert_code, region)
    VALUES (?, ?, ?, ?, ?, ?, ?, ?)
"""
    prepared = session.prepare(query)

    for _, row in sample_df.iterrows():
        session.execute(prepared, (
            str(row['sensor_id']),
            str(row['timestamp']),
            str(row['installation_id']),
            float(row['solar_output_w']),
            float(row['battery_level_pct']),
            float(row['consumption_w']),
            str(row['alert_code']),
            str(row['region'])
        ))

    print("✅ Succès total ! Les données massives sont stockées dans Cassandra.", flush=True)

except Exception as e:
    print(f"❌ Une erreur est survenue sur Cassandra : {e}", flush=True)
finally:
    if 'cluster' in locals():
        cluster.shutdown()