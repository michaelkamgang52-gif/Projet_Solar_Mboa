import json
import os
import sys
from pymongo import MongoClient

print("🔄 Initialisation du script...", flush=True)

# 1. Définition des chemins d'accès
BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
FILE_PATH = os.path.join(BASE_DIR, "data", "installations.json")

print(f"📂 Chemin du fichier recherché : {FILE_PATH}", flush=True)

try:
    print("🔄 Tentative de connexion à MongoDB Docker (Timeout 5s)...", flush=True)
    # Connexion avec sécurité en cas de panne du conteneur (5 secondes max)
    client = MongoClient("mongodb://admin:SolarMboaPassword2026@localhost:27017/", serverSelectionTimeoutMS=5000)
    
    # Force Python à vérifier si le serveur répond vraiment
    client.server_info() 
    print("✅ Connexion réussie au serveur MongoDB !", flush=True)
    
    db = client["solarmboa_db"]
    collection = db["installations"]

    # 2. Lecture et injection des données
    print("📖 Lecture du fichier installations.json...", flush=True)
    with open(FILE_PATH, "r", encoding="utf-8") as file:
        data = json.load(file)
        
    print("📥 Injection des données dans la base...", flush=True)
    if isinstance(data, list):
        result = collection.insert_many(data)
        print(f"✅ Succès ! {len(result.inserted_ids)} profils d'installations importés.", flush=True)
    else:
        result = collection.insert_one(data)
        print("✅ Succès ! 1 profil d'installation importé.", flush=True)

except FileNotFoundError:
    print(f"❌ Erreur : Le fichier est introuvable à l'emplacement : {FILE_PATH}", flush=True)
    print("👉 Vérifiez que le fichier 'installations.json' est bien dans votre dossier 'data'.", flush=True)
except Exception as e:
    print(f"❌ Une erreur est survenue lors de l'exécution : {e}", flush=True)
