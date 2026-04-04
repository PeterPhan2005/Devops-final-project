variable "project_id"   { type = string }
variable "project_name" { type = string }
variable "environment"  { type = string }
variable "gcp_region"  { type = string }

# Cloud NAT: enables private GKE nodes to pull images from external registries
# (quay.io, ghcr.io, DockerHub). Without NAT, nodes can only reach
# GCP APIs via Private Google Access (GAR, GCR) but not public internet.
resource "google_compute_router" "nat" {
  name    = "${var.project_name}-router"
  network = google_compute_network.main.name
  region  = var.gcp_region
}

resource "google_compute_address" "nat_ip" {
  name         = "${var.project_name}-nat-ip"
  region       = var.gcp_region
  address_type = "EXTERNAL"
  network_tier = "PREMIUM"
}

resource "google_compute_router_nat" "main" {
  name                               = "${var.project_name}-nat"
  router                             = google_compute_router.nat.name
  region                             = var.gcp_region
  nat_ip_allocate_option             = "MANUAL_ONLY"
  nat_ips                            = [google_compute_address.nat_ip.self_link]
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  # Allow this NAT to handle all traffic from the GKE subnet
  # (only this project's subnet is on this router)
  enable_endpoint_independent_mapping = false
}

output "nat_ip_address" {
  description = "Cloud NAT IP address"
  value       = google_compute_address.nat_ip.address
}

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

# Network ID (not self_link) — required by Filestore for network project mismatch
output "vpc_network_id" {
  value = google_compute_network.main.id
}

output "subnetwork_name" {
  value = google_compute_subnetwork.gke.name
}

# ── Global Static IPs ─────────────────────────────────────────────

# Main application static IP (used by doc-system-ingress)
# NOTE: purpose/ip_version intentionally omitted — GCP returns empty string for
# IN_USE global addresses, causing terraform drift. The IPs are already correctly
# allocated as GLOBAL (used by GKE ingress forwarding rules).
resource "google_compute_global_address" "app" {
  project = var.project_id
  name    = "${var.project_name}-final"
}

# Grafana static IP (used by grafana-ingress + ManagedCertificate)
resource "google_compute_global_address" "grafana" {
  project = var.project_id
  name    = "grafana-ip"
}

output "app_static_ip" {
  description = "Static IP for main application"
  value      = google_compute_global_address.app.address
}

output "grafana_static_ip" {
  description = "Static IP for Grafana dashboard"
  value      = google_compute_global_address.grafana.address
}

output "app_static_ip_name" {
  description = "Static IP resource name for main application ingress"
  value      = google_compute_global_address.app.name
}

output "grafana_static_ip_name" {
  description = "Static IP resource name for Grafana ingress"
  value      = google_compute_global_address.grafana.name
}
