terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = "solarmboa-technologies"
  region  = "europe-west9" # Région recommandée pour la souveraineté/proximité
}

# ======================================================
# 1. RÉSEAUX VPC (STAGING & PRODUCTION)
# ======================================================

# VPC de Staging (Audit de coûts FinOps)
resource "google_compute_network" "vpc_staging" {
  name                    = "solarmboa-vpc-staging"
  auto_create_subnetworks = false
}

# VPC de Production (Environnement critique cloisonné)
resource "google_compute_network" "vpc_prod" {
  name                    = "solarmboa-vpc-prod"
  auto_create_subnetworks = false
}

# ======================================================
# 2. SOUS-RÉSEAUX (SUBNETS) POUR LA PRODUCTION
# ======================================================

# Subnet 1: Ingestion des 5285 capteurs IoT
resource "google_compute_subnetwork" "subnet_prod_ingestion" {
  name          = "solarmboa-subnet-prod-ingestion"
  ip_cidr_range = "10.0.1.0/24"
  region        = "europe-west9"
  network       = google_compute_network.vpc_prod.id
  
  # Sécurité : Empêche l'attribution automatique d'IP publiques aux machines
  private_ip_google_access = true
}

# Subnet 2: Pipeline de traitement de données (dbt, Delta Lake)
resource "google_compute_subnetwork" "subnet_prod_processing" {
  name          = "solarmboa-subnet-prod-processing"
  ip_cidr_range = "10.0.2.0/24"
  region        = "europe-west9"
  network       = google_compute_network.vpc_prod.id
  private_ip_google_access = true
}

# ======================================================
# 3. RÈGLES DE PARE-FEU (FIREWALL) - SÉCURITÉ ABSOLUE
# ======================================================

# Règle Ingress : Autoriser uniquement le trafic IoT HTTPS entrant
resource "google_compute_firewall" "allow_iot_traffic" {
  name    = "solarmboa-fw-prod-allow-iot"
  network = google_compute_network.vpc_prod.name

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }

  source_ranges = ["0.0.0.0/0"] # Seul point d'entrée public pour les kits solaires
  target_tags   = ["iot-gateway"]
}

# Règle par défaut : Bloquer tout le reste (Deny All implicite de GCP)
