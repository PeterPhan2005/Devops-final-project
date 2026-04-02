# ============================================================
# Google Cloud Filestore — NFS Share for shared document uploads
# Replaces Standard PD (RWO) to enable HPA multi-pod scaling.
#
# Filestore provides ReadWriteMany (RWX) — multiple pods across
# multiple nodes can mount the same volume simultaneously.
#
# Instance: doc-system-filestore
# Share:   /doc-uploads  (1Ti capacity, sufficient for document storage)
# VPC:     Shared VPC so GKE nodes in any subnet can access
# ============================================================

variable "project_id"   { type = string }
variable "project_name" { type = string }
variable "gcp_region"   { type = string }
variable "vpc_network"  { type = string }    # VPC self_link for Filestore placement

resource "google_filestore_instance" "main" {
  project = var.project_id
  name    = "${var.project_name}-filestore"
  region  = var.gcp_region

  tier = "BASIC_HDD"   # $0.06/GB/month — cost-effective for documents

  file_shares {
    capacity_gb = 1024          # 1 TiB = 1024 GiB
    name        = "doc-uploads" # NFS export path: /doc-uploads
  }

  network {
    name         = var.vpc_network
    connect_mode = "DIRECT_PEERING"  # Low-latency, no internet
  }
}

# Output: Filestore NFS IP (used by PVC to connect)
output "nfs_ip" {
  description = "Filestore instance IP address"
  value       = google_filestore_instance.main.networks[0].ip_addresses[0]
}

# Output: NFS export path (used by PVC)
output "nfs_path" {
  description = "Filestore NFS export path"
  value       = "/${google_filestore_instance.main.file_shares[0].name}"
}

# Output: Filestore instance name
output "instance_name" {
  description = "Filestore instance name"
  value       = google_filestore_instance.main.name
}
