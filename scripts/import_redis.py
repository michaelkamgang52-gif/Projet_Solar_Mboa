import os
import sys
import pandas as pd
import redis

print("🔄 Initialisation du script Redis...", flush=True)

# 1. Définition des chemins
BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
FILE_PATH = os.path.join(BASE_DIR, "data", "sensors_telemetry.csv")

print(f"📂 Chemin du fichier recherché : {FILE_PATH}", flush=True)

try:
    print("🔄 Connexion à Redis Docker...", flush=True)
    r = redis.Redis(host='localhost', port=6379, decode_responses=True, socket_timeout=5)
    
    # Tester la connexion active
    r.ping()
    print("✅ Connexion réussie à Redis !", flush=True)
    
    print("📖 Lecture du fichier de télémétrie...", flush=True)
    df = pd.read_csv(FILE_PATH)
    
    # Adaptation à vos colonnes : sensor_id et alert_code
    print("🧹 Extraction des codes d'alerte par capteur...", flush=True)
    compteurs = df[['sensor_id', 'alert_code']].drop_duplicates(subset=['sensor_id'])
    
    print("📥 Ingestion des données dans le cache Redis...", flush=True)
    pipe = r.pipeline()
    for _, row in compteurs.iterrows():
        # Stockage de l'alerte pour chaque capteur
        # Clé Redis : "compteur:[ID]" -> Valeur : [Code Alerte]
        pipe.set(f"compteur:{row['sensor_id']}", str(row['alert_code']))
    
    pipe.execute()
    print(f"✅ Succès ! {len(compteurs)} capteurs uniques mis en cache dans Redis.", flush=True)

except redis.exceptions.TimeoutError:
    print("❌ Erreur : Impossible de se connecter à Redis (Timeout). Vérifiez le conteneur.", flush=True)
except FileNotFoundError:
    print(f"❌ Erreur : Le fichier est introuvable à l'emplacement : {FILE_PATH}", flush=True)
except Exception as e:
    print(f"❌ Une erreur est survenue : {e}", flush=True)
