# 📌 FICHE DE DÉCISION ARCHITECTURALE (ADR)
# Théorème CAP et choix des bases NoSQL

---

## 📋 Informations générales

| Élément | Description |
|---|---|
| **Projet** | Modernisation de la plateforme IoT SolarMboa Technologies |
| **Sujet** | Décision architecturale basée sur le Théorème CAP |
**Formation** | Ingénieur Data & Intelligence Artificielle |
| **Auteur** | KAMGANG TONGAMBOU Michael|
| **Date** | Juillet 2026 |
| **Architecture** | Architecture NoSQL Polyglotte |

---

# 1. Rappel du Théorème CAP

Le **théorème CAP (Brewer's Theorem)** explique qu'un système distribué ne peut garantir simultanément les trois propriétés fondamentales suivantes :

- **C — Consistency (Cohérence)**
- **A — Availability (Disponibilité)**
- **P — Partition Tolerance (Tolérance au partitionnement)**

Dans un environnement distribué réel, les partitions réseau sont inévitables.  
L'architecture doit donc effectuer un compromis entre :

- **CP : Cohérence + Tolérance au partitionnement**
- **AP : Disponibilité + Tolérance au partitionnement**

---

# 2. Définition des propriétés CAP

## 2.1 Cohérence (Consistency - C)

La cohérence signifie que tous les nœuds du système possèdent la même information au même moment.

Exemple :

Une modification de configuration d'une installation solaire doit être immédiatement visible par tous les services utilisant cette donnée.

---

## 2.2 Disponibilité (Availability - A)

La disponibilité garantit que chaque requête reçoit une réponse, même si celle-ci correspond temporairement à une version légèrement ancienne de la donnée.

Objectif :

- Continuer à fournir un service même pendant certaines perturbations.

---

## 2.3 Tolérance au partitionnement (Partition Tolerance - P)

La tolérance au partitionnement signifie que le système continue de fonctionner malgré une rupture de communication entre plusieurs nœuds.

Dans une architecture IoT comme SolarMboa, les interruptions réseau sont considérées comme inévitables.

---

# 3. Matrice d'arbitrage CAP de SolarMboa Technologies

| Technologie | Fonction principale | Choix CAP |
|---|---|---|
| MongoDB | Gestion des profils et configurations clients | CP |
| Cassandra | Stockage massif des événements IoT | AP |
| InfluxDB | Analyse des séries temporelles | AP |
| Redis | Cache temps réel | AP orienté performance |
| Neo4j | Graphe réseau et détection de fraude | CA local |

---

# 4. Analyse détaillée des choix architecturaux

---

# 🏢 4.1 MongoDB : Gestion des profils d'installations clients

## Positionnement CAP

**Choix : CP (Cohérence + Tolérance au partitionnement)**

---

## Justification métier

MongoDB est utilisé pour stocker :

- les profils clients ;
- les contrats ;
- les configurations techniques des installations solaires ;
- les informations des équipements.

Ces données nécessitent une cohérence stricte.

Exemple :

> Si un technicien modifie la configuration d'un panneau solaire à Douala, cette modification doit être identique pour le service client situé à Yaoundé.

En cas de panne réseau :

- MongoDB privilégie la cohérence ;
- les écritures peuvent être temporairement limitées ;
- les conflits de données sont évités.

---

# 📈 4.2 Cassandra & InfluxDB : Télémétrie IoT massive

## Positionnement CAP

**Choix : AP (Disponibilité + Tolérance au partitionnement)**

---

## Justification métier

La plateforme SolarMboa collecte continuellement :

- production solaire ;
- tension électrique ;
- courant ;
- température ;
- niveau de batterie ;
- événements provenant des capteurs IoT.

Le système doit accepter les données même lorsque la connexion réseau est instable.

---

## Fonctionnement avec Cassandra

Cassandra utilise une stratégie de :

**Cohérence éventuelle (Eventual Consistency)**

Processus :

1. La donnée est enregistrée immédiatement sur un nœud disponible.
2. Le système continue son fonctionnement.
3. Les autres nœuds sont synchronisés ultérieurement.

Avantages :

- haute disponibilité ;
- résistance aux pannes ;
- grande capacité d'ingestion.

---

# ⚡ 4.3 Redis : Cache des compteurs actifs et commandes temps réel

## Positionnement CAP

**Choix : AP orienté performance**

---

## Justification métier

Redis est utilisé comme base mémoire rapide (*In-Memory Database*) pour :

- vérifier l'état des compteurs ;
- accélérer les accès fréquents ;
- gérer les commandes temps réel.

Exemple :

Lors d'une demande de recharge énergétique :

1. Redis vérifie instantanément l'état du compteur.
2. La réponse est obtenue avec une très faible latence.

Le choix privilégie :

- la rapidité ;
- la disponibilité ;
- la performance.

---

# 🔗 4.4 Neo4j : Cartographie du réseau et détection de fraude

## Positionnement CAP

**Choix : CA au niveau d'un nœud unique**

---

## Justification métier

Neo4j représente les relations complexes :

```
Distributeur
      |
      |
Technicien
      |
      |
Installation solaire
      |
      |
Équipement
```

Le graphe permet :

- l'analyse des connexions ;
- la détection de comportements suspects ;
- l'identification des anomalies.

---

## Garanties Neo4j

Neo4j assure :

- transactions ACID ;
- intégrité des relations ;
- cohérence des données graphiques.

Cependant :

- la scalabilité horizontale est plus limitée que Cassandra ;
- la cohérence des relations est prioritaire.

---

# 5. Architecture NoSQL Polyglotte SolarMboa

SolarMboa adopte une architecture **NoSQL Polyglotte**.

Chaque technologie est utilisée selon son domaine d'excellence.

| Besoin métier | Technologie | Rôle |
|---|---|---|
| Profils clients et contrats | MongoDB | Cohérence documentaire |
| Flux IoT massif | Cassandra | Haute disponibilité |
| Données temporelles | InfluxDB | Analyse séries temporelles |
| Accès instantané | Redis | Cache haute performance |
| Relations complexes | Neo4j | Analyse graphique |

---

# 6. Conclusion de la décision architecturale

L'entreprise **SolarMboa Technologies** ne pouvait pas utiliser une seule base de données pour gérer l'ensemble de son système IoT.

L'approche NoSQL polyglotte permet d'adapter chaque technologie au besoin réel :

- **MongoDB** garantit la cohérence des données métier.
- **Cassandra et InfluxDB** assurent la collecte massive des données IoT.
- **Redis** apporte une réponse temps réel.
- **Neo4j** assure l'analyse des relations complexes.

---

# ✅ Décision finale

> SolarMboa Technologies adopte une architecture NoSQL polyglotte combinant des stratégies CP et AP selon la criticité des données.

Cette architecture garantit :

- ✅ Scalabilité
- ✅ Résilience
- ✅ Haute disponibilité
- ✅ Performance temps réel
- ✅ Adaptation aux contraintes IoT distribuées

---

**Fin de la fiche ADR — Théorème CAP SolarMboa Technologies**