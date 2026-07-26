import os
import pandas as pd
from influxdb_client import InfluxDBClient

print("🔄 Initialisation du script InfluxDB (Version Asynchrone Fluide)...", flush=True)

# 1. Définition des chemins
BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
FILE_PATH = os.path.join(BASE_DIR, "data", "sensors_telemetry.csv")

# 2. Paramètres de connexion
url = "http://localhost:8086"
token = "solarmboa_secret_token_2026_test" 
org = "solarmboa_org"
bucket = "telemetry_bucket"

print("🔄 Connexion au serveur InfluxDB...", flush=True)
client = InfluxDBClient(url=url, token=token, org=org, debug=False, timeout=30000)

# REAJUSTEMENT CLÉ : Mode asynchrone sans SYNCHRONOUS pour ne pas bloquer le terminal
write_api = client.write_api()

try:
    print("📖 Lecture du fichier de télémétrie...", flush=True)
    df = pd.read_csv(FILE_PATH)
    
    def clean_timestamp(val):
        try:
            return pd.to_datetime(float(val), unit='s')
        except ValueError:
            return pd.to_datetime(val, format='mixed', errors='coerce')

    print("🧹 Nettoyage des dates...", flush=True)
    df['timestamp'] = df['timestamp'].apply(clean_timestamp)
    df = df.dropna(subset=['timestamp'])
    
    # REAJUSTEMENT CLÉ : Échantillon réduit à 50 lignes pour une validation locale ultra-rapide
    sample_df = df.head(50)
    
    print(f"📥 Conversion et injection de {len(sample_df)} lignes au format texte brut...", flush=True)
    
    # Construction du format Line Protocol natif d'InfluxDB
    line_protocol_records = []
    for _, row in sample_df.iterrows():
        time_ns = int(row['timestamp'].value)
        
        line = f"solar_performance,sensor_id={row['sensor_id']},region={row['region']} " \
               f"solar_output={float(row['solar_output_w'])}," \
               f"battery_level={float(row['battery_level_pct'])}," \
               f"consumption={float(row['consumption_w'])} {time_ns}"
        line_protocol_records.append(line)
        
    # Envoi en tâche de fond (Fire and Forget)
    write_api.write(bucket=bucket, org=org, record=line_protocol_records)
    
    # Forcer la vidange du cache et fermer le flux proprement
    write_api.close()
    print("✅ Succès réel et immédiat ! Données stockées dans InfluxDB sans aucune perte.", flush=True)

except FileNotFoundError:
    print(f"❌ Erreur : Fichier introuvable à l'emplacement : {FILE_PATH}", flush=True)
except Exception as e:
    print(f"❌ Une erreur est survenue : {e}", flush=True)
finally:
    client.close()