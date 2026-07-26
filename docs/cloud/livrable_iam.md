#  Livrable 2 : Matrice des Rôles IAM (Sécurité by Design)

Pour sécuriser l'accès aux données des kits solaires, l'attribution des droits suit strictement le principe du moindre privilège. Les rôles primitifs (Owner/Editor) sont proscrits.

### 1. Comptes de Service (Automates)

| Identifiant du Compte de Service | Rôle GCP Précis (ID) | Justification Métier |
| :--- | :--- | :--- |
| `sa-iot-ingestion@...` | `roles/pubsub.publisher` | Autorise la passerelle IoT à publier les mesures des 5 285 capteurs, sans accès aux bases de données. |
| `sa-data-pipeline@...` | `roles/storage.objectUser`<br>`roles/bigquery.dataEditor` | Permet aux scripts de traitement (dbt / Delta Lake) de lire le dossier Bronze et d'écrire dans le Data Warehouse. |
| `sa-bi-analytics@...` | `roles/bigquery.dataViewer`<br>`roles/bigquery.jobUser` | Donne un accès en lecture seule à Looker Studio pour afficher les tableaux de bord de la direction sans risque d'altération. |

### 2. Comptes Utilisateurs (Humains)

| Équipe Métier | Rôle Réduit Accordé | Périmètre d'Action Autorisé |
| :--- | :--- | :--- |
| **Data Engineers** | `roles/dataflow.developer`<br>`roles/storage.admin` | Déploiement et maintenance des pipelines de données et gestion des architectures de stockage. |
| **Data Analysts / BI** | `roles/bigquery.user` | Requêtage SQL uniquement sur la couche de données nettoyées (Gold), interdiction de modifier l'infrastructure. |
| **Techniciens de Maintenance**| `roles/iap.tunnelResourceAccessor` | Accès distant sécurisé via IAP pour la maintenance technique sans exposition d'IP publique. |