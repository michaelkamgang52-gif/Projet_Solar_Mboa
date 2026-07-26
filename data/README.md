# SolarMboa Technologies – Dictionnaire des Données
## Projet 2 | DHI Academy | Mois 2

Généré le : 28 March 2026

---

## Fichiers disponibles

| Fichier | Lignes | Description |
|---------|--------|-------------|
| installations.json | 4,800 | Profils complets des installations |
| sensors_telemetry.csv | 120,960 | Relevés IoT des capteurs (25 jours) |
| payments.csv | 28,140 | Transactions de paiement |
| network_graph.csv | 10,514 | Arêtes du réseau de distribution |
| network_nodes_distributors.csv | 38 | Noeuds Distributeurs |
| network_nodes_technicians.csv | 210 | Noeuds Techniciens |
| schema_solarmboa.sql | - | Schéma MySQL de référence |

---

## Problèmes de qualité intentionnels (à détecter)

### sensors_telemetry.csv
- Timestamps en 5 formats différents (unix epoch, ISO 8601, DD/MM/YYYY HH:MM, etc.)
- `battery_level_pct` > 100 pour ~2% des lignes (bug firmware v1.x)
- `solar_output_w` NULL la nuit (normal) + ~3% de NULLs aléatoires
- `alert_code` : mêmes codes en MAJUSCULES et minuscules (ex: OVR_V / ovr_v)
- `region` : abréviations et casses variables (ex: "Ext-Nord", "EXTREME-NORD", "extreme-nord")
- ~960 doublons exacts introduits (~0.8%)

### payments.csv
- `payment_date` en 4 formats différents
- `amount_xaf` négatif pour ~3% (remboursements non séparés)
- `amount_xaf` = 0 pour ~1% (bugs système)
- ~140 doublons (suffix -DUP) simulant des double-soumissions API
- `operator_code` NULL pour les paiements cash + ~2% manquants aléatoirement

### installations.json
- `gps_lat` / `gps_lon` NULL pour ~8% des installations
- `install_date` en formats de dates variés
- `client_name` : casse et formatage variables (NOM Prénom / prénom NOM / PRÉNOM NOM)

### network_graph.csv
- 15 techniciens avec des arêtes MAINTAINS vers des installations hors de leur région
  (anomalie de fraude à détecter avec Neo4j)

---

## Périmètre géographique

Regions couvertes : Littoral (30%), Centre (22%), Ouest (15%),
Nord-Ouest (12%), Adamaoua (8%), Est (7%), Extrême-Nord (6%)

---

## Codes d'alerte capteurs (sensor_readings.alert_code)

| Code | Signification |
|------|--------------|
| OVR_V / ovr_v | Surtension détectée |
| LOW_BAT / low_bat | Batterie faible (< 15%) |
| NO_SIG | Perte de signal de communication |
| FAULT_01 / FAULT_02 | Défaut matériel générique |
| ERR | Erreur non classifiée |
| OVERCURRENT | Surintensité |
| TAMPER | Manipulation physique suspecte du boîtier |
