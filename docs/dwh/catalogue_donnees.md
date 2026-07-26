#  Livrable : Catalogue des Données Métier (Couche Gold)

Ce catalogue répertorie les structures prêtes pour l'analyse décisionnelle de la direction de SolarMboa.

###  Table 1 : `gold_energy_production` (Performance des Panneaux)
*   **Description** : Vue consolidée des performances de production d'énergie solaire nettoyée de toute anomalie de date ou doublon.
*   **Propriétaire (Data Owner)** : Équipe Data Engineering / Responsable Infrastructure IoT.
*   **Fréquence de mise à jour (Fraîcheur)** : Toutes les 15 minutes (Flux Batch rapproché).
*   **SLA de disponibilité** : 99.9% en journée.
*   **Exemple de requête analyste (Calcul du rendement moyen par région)** :
    ```sql
    SELECT region_key, AVG(solar_output_w) as rendement_moyen 
    FROM `solarmboa_gold.gold_energy_production` 
    GROUP BY region_key;
    ```

###  Table 2 : `gold_financial_payments` (Suivi de Facturation PAYG)
*   **Description** : Historique des paiements consolidés par client pour suivre la santé financière des abonnements de kits solaires.
*   **Propriétaire (Data Owner)** : Direction Financière (FinOps Officer).
*   **Fréquence de mise à jour** : Une fois par jour (Calcul nocturne à 02h00).
*   **SLA de disponibilité** : Données prêtes avant 06h00 chaque matin.
*   **Exemple de requête analyste (Détection des baisses de chiffre d'affaires)** :
    ```sql
    SELECT DATE_TRUNC(payment_date, MONTH) as mois, SUM(amount) as CA_total 
    FROM `solarmboa_gold.gold_financial_payments` 
    GROUP BY mois ORDER BY mois DESC;
    ```
