import os
import pandas as pd
from neo4j import GraphDatabase

print("🔄 Initialisation du script Neo4j...", flush=True)

# 1. Définition des chemins vers les 3 fichiers du graphe
BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
NODES_DIST_PATH = os.path.join(BASE_DIR, "data", "network_nodes_distributors.csv")
NODES_TECH_PATH = os.path.join(BASE_DIR, "data", "network_nodes_technicians.csv")
EDGES_PATH = os.path.join(BASE_DIR, "data", "network_graph.csv")

# 2. Connexion à Neo4j Docker (identifiants définis dans votre docker-compose)
URI = "bolt://localhost:7687"
AUTH = ("neo4j", "SolarMboaPassword2026")

try:
    print("🔄 Connexion à la base de graphes Neo4j...", flush=True)
    driver = GraphDatabase.driver(URI, auth=AUTH)
    
    with driver.session() as session:
        # Nettoyage de sécurité de la base locale avant injection
        print("🧹 Nettoyage de la base de données...", flush=True)
        session.run("MATCH (n) DETACH DELETE n")

        # A. Importation des Distributeurs
        print("📥 Injection des nœuds Distributeurs...", flush=True)
        df_dist = pd.read_csv(NODES_DIST_PATH)
        for _, row in df_dist.iterrows():
            session.run(
                "CREATE (d:Distributor {id: $id, name: $name, region: $region})",
                id=str(row.iloc[0]), name=str(row.iloc[1]), region=str(row.iloc[2])
            )

        # B. Importation des Techniciens
        print("📥 Injection des nœuds Techniciens...", flush=True)
        df_tech = pd.read_csv(NODES_TECH_PATH)
        for _, row in df_tech.iterrows():
            session.run(
                "CREATE (t:Technician {id: $id, name: $name, specialization: $specialization})",
                id=str(row.iloc[0]), name=str(row.iloc[1]), specialization=str(row.iloc[2])
            )

        # C. Ingestion des Relations (Liens de distribution / Assignations)
        print("🔗 Création des relations du réseau...", flush=True)
        df_edges = pd.read_csv(EDGES_PATH)
        for _, row in df_edges.iterrows():
            session.run(
                """
                MATCH (a {id: $source}), (b {id: $target})
                CREATE (a)-[r:CONNECTED {type: $type}]->(b)
                """,
                source=str(row.iloc[0]), target=str(row.iloc[1]), type=str(row.iloc[2])
            )

        print(f"✅ Succès ! Graphe réseau SolarMboa injecté avec succès dans Neo4j.", flush=True)

except FileNotFoundError as e:
    print(f"❌ Erreur : Fichier introuvable. Détails : {e}", flush=True)
except Exception as e:
    print(f"❌ Une erreur est survenue : {e}", flush=True)
finally:
    if 'driver' in locals():
        driver.close()
