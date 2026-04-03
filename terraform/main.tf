terraform {
  required_version = ">= 1.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 5.0"
    }
  }

  backend "gcs" {
    bucket = "doc-system-terraform-state-pete" # Đổi tên bucket cho đúng
    prefix = "prod"
  }
}

# VPC Network
module "vpc" {
  source       = "./vpc"
  project_id   = var.project_id
  project_name = var.project_name
  environment  = var.environment
  gcp_region   = var.gcp_region
}

# GKE Cluster
module "gke" {
  source        = "./gke"
  project_id    = var.project_id
  project_name  = var.project_name
  environment   = var.environment
  gcp_region    = var.gcp_region
  gcp_zone      = var.gcp_zone
  vpc_network   = module.vpc.vpc_network_name
  subnetwork    = module.vpc.subnetwork_name
  pod_cidr      = "10.4.0.0/16"
  services_cidr = "10.5.0.0/16"
}

# Cloud SQL (PostgreSQL) - dùng self_link cho service networking
module "cloud-sql" {
  source       = "./cloud-sql"
  project_id   = var.project_id
  project_name = var.project_name
  environment  = var.environment
  gcp_region   = var.gcp_region
  vpc_network  = module.vpc.vpc_self_link
  db_name      = var.db_name
  db_username  = var.db_username
  db_password  = var.db_password
}

# Artifact Registry
module "registry" {
  source       = "./registry"
  project_id   = var.project_id
  project_name = var.project_name
  gcp_region   = var.gcp_region
}

# Filestore NFS — shared file storage for document uploads (enables HPA multi-pod)
module "filestore" {
  source       = "./filestore"
  project_id   = var.project_id
  project_name = var.project_name
  gcp_region   = var.gcp_region
  gcp_zone     = var.gcp_zone
  vpc_network  = module.vpc.vpc_network_id
}
