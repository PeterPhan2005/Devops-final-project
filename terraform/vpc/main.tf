variable "project_name" { type = string }
variable "environment" { type = string }
variable "gcp_region" { type = string }

resource "google_compute_network" "main" {
  name                    = "${var.project_name}-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "gke" {
  name                     = "${var.project_name}-gke-subnet"
  network                  = google_compute_network.main.name
  ip_cidr_range            = "10.0.0.0/20"
  region                   = var.gcp_region
  private_ip_google_access = true

  secondary_ip_range {
    range_name    = "pod-range"
    ip_cidr_range = "10.4.0.0/16"
  }

  secondary_ip_range {
    range_name    = "svc-range"
    ip_cidr_range = "10.5.0.0/20"
  }
}

resource "google_compute_firewall" "allow-internal" {
  name          = "${var.project_name}-allow-internal"
  network       = google_compute_network.main.name
  source_ranges = ["10.0.0.0/8"]

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }
  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }
  allow {
    protocol = "icmp"
  }
}

resource "google_compute_firewall" "allow-health-checks" {
  name          = "${var.project_name}-allow-health-checks"
  network       = google_compute_network.main.name
  source_ranges = ["35.191.0.0/16", "130.211.0.0/22"]

  allow {
    protocol = "tcp"
    ports    = ["80", "443", "8080"]
  }
}

output "vpc_network_name" {
  value = google_compute_network.main.name
}

output "vpc_self_link" {
  value = google_compute_network.main.self_link
}

output "subnetwork_name" {
  value = google_compute_subnetwork.gke.name
}
