#  Livrable 4 : Architecture de Stockage Objet (Google Cloud Storage)

Pour moderniser la plateforme de SolarMboa Technologies, le stockage des données suit les principes d'un **Data Lake Lakehouse** organisé en couches étanches. L'infrastructure est entièrement automatisée via Terraform avec des règles de gouvernance strictes.

---

### 1. Organisation du Data Lake (Architecture en Couches)

####  Couche BRONZE (`solarmboa-data-lake-bronze`)
*   **Rôle** : Zone d'atterrissage (Landing Zone) des données brutes de télémétrie issues des 5 285 capteurs solaires. Les fichiers CSV et JSON y sont stockés dans leur format d'origine sans aucune modification.
*   **Classe de Stockage initiale** : `STANDARD` (Haute disponibilité pour l'ingestion et la lecture par le pipeline de traitement).

####  Couche GOLD (`solarmboa-data-lake-gold`)
*   **Rôle** : Zone des données hautement agrégées, nettoyées et structurées (Schéma en étoile). Ces données sont directement prêtes à être consommées par Looker Studio et les équipes BI pour le suivi de la production d'énergie.
*   **Classe de Stockage initiale** : `STANDARD`.

---

### 2. Automatisation des Politiques FinOps (Cycle de Vie)

Le stockage continu de fichiers de télémétrie haute fréquence génère des coûts exponentiels. Pour respecter le budget, une règle de cycle de vie (Lifecycle Management) a été implémentée dans Terraform sur la couche **Bronze** :
*   **Règle de transition** : Tout fichier brut atteignant **30 jours d'ancienneté** bascule automatiquement de la classe `STANDARD` à la classe `NEARLINE`.
*   **Impact FinOps** : Le coût du stockage est divisé par deux pour les données historiques froides (qui ne servent plus qu'aux audits ou aux ré-entraînements de modèles IA), tout en restant accessibles en cas de besoin.

---

### 3. Mesures de Sécurité Appliquées (Security by Design)

Pour répondre aux exigences strictes d'Hervé Atangana Obama et éviter toute fuite de données :
1.  **Prévention de l'accès public (`public_access_prevention = "enforced"`)** : Cette option Terraform verrouille les Buckets au niveau de l'API Google. Même si un développeur fait une erreur de manipulation, aucun fichier ne pourra jamais être partagé publiquement sur Internet.
2.  **Chiffrement au repos** : Toutes les données stockées dans les buckets Bronze et Gold sont chiffrées par défaut à l'aide des clés gérées par Google (Google-Managed Encryption Keys).
3.  **Contrôle d'accès IAM Uniforme** : L'accès aux objets est géré exclusivement au niveau du Bucket (et non par fichier individuel ACL), ce qui garantit un audit de sécurité simplifié et sans faille.