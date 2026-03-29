variable "project_id" { type = string }
variable "project_name" { type = string }
variable "environment" { type = string }
variable "gcp_region" { type = string }
variable "gcp_zone" { type = string }
variable "vpc_network" { type = string }
variable "subnetwork" { type = string }
variable "pod_cidr" { type = string }
variable "services_cidr" { type = string }

# GKE Cluster
resource "google_container_cluster" "main" {
  project                  = var.project_id
  name                     = "${var.project_name}-cluster"
  location                 = var.gcp_region
  remove_default_node_pool = true
  initial_node_count       = 1

  network    = var.vpc_network
  subnetwork = var.subnetwork

  ip_allocation_policy {
    cluster_secondary_range_name  = "pod-range"
    services_secondary_range_name = "svc-range"
  }

  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = false
    master_ipv4_cidr_block  = "172.16.0.0/28"
  }

  master_authorized_networks_config {
    cidr_blocks {
      cidr_block   = "0.0.0.0/0"
      display_name = "Allow all"
    }
  }

  addons_config {
    http_load_balancing {
      disabled = false
    }
    horizontal_pod_autoscaling {
      disabled = false
    }
  }

  enable_shielded_nodes = true

  release_channel {
    channel = "STABLE"
  }

  vertical_pod_autoscaling {
    enabled = true
  }

  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  node_locations = [var.gcp_zone]

  resource_labels = {
    environment = var.environment
    project     = var.project_name
  }
}

# Node Pool
resource "google_container_node_pool" "main" {
  project            = var.project_id
  name               = "${var.project_name}-nodepool"
  location           = var.gcp_region
  cluster            = google_container_cluster.main.name
  initial_node_count = 2

  node_config {
    machine_type = "e2-small"
    disk_type    = "pd-standard"
    disk_size_gb = 20
    spot         = true

    service_account = google_service_account.gke_sa.email

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]

    shielded_instance_config {
      enable_secure_boot          = false
      enable_integrity_monitoring = true
    }

    labels = {
      "project"     = var.project_name
      "environment" = var.environment
    }
  }

  autoscaling {
    min_node_count = 1
    max_node_count = 4
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  lifecycle {
    ignore_changes = [initial_node_count]
  }

  depends_on = [
    google_container_cluster.main
  ]
}

# Service Account cho GKE nodes
resource "google_service_account" "gke_sa" {
  project      = var.project_id
  account_id   = "${var.project_name}-gke-sa"
  display_name = "GKE Service Account"
}

resource "google_project_iam_member" "gke_sa_storage" {
  project = var.project_id
  role    = "roles/storage.objectViewer"
  member  = "serviceAccount:${google_service_account.gke_sa.email}"
}

resource "google_project_iam_member" "gke_sa_cloudsql" {
  project = var.project_id
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:${google_service_account.gke_sa.email}"
}

resource "google_project_iam_member" "gke_sa_artifact" {
  project = var.project_id
  role    = "roles/artifactregistry.reader"
  member  = "serviceAccount:${google_service_account.gke_sa.email}"
}

# Outputs
output "cluster_name" {
  value = google_container_cluster.main.name
}

output "cluster_endpoint" {
  value     = google_container_cluster.main.endpoint
  sensitive = true
}

output "cluster_location" {
  value = google_container_cluster.main.location
}

output "gke_service_account_email" {
  value = google_service_account.gke_sa.email
}
