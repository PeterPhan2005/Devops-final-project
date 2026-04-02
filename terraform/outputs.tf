output "cluster_endpoint" {
  description = "GKE cluster endpoint"
  value       = module.gke.cluster_endpoint
  sensitive   = true
}

output "cluster_name" {
  description = "GKE cluster name"
  value       = module.gke.cluster_name
}

output "cluster_location" {
  description = "GKE cluster location"
  value       = module.gke.cluster_location
}

output "sql_private_ip" {
  description = "Cloud SQL private IP"
  value       = module.cloud-sql.sql_instance_private_ip
}

output "sql_connection_name" {
  description = "Cloud SQL connection name"
  value       = module.cloud-sql.sql_instance_connection_name
}

output "artifact_registry_url" {
  description = "Artifact Registry URL"
  value       = module.registry.registry_url
}

output "vpc_name" {
  description = "VPC network name"
  value       = module.vpc.vpc_network_name
}

output "app_static_ip" {
  description = "Static IP for main application (doc-system)"
  value       = module.vpc.app_static_ip
}

output "grafana_static_ip" {
  description = "Static IP for Grafana dashboard"
  value       = module.vpc.grafana_static_ip
}

output "filestore_nfs_ip" {
  description = "Filestore NFS IP address"
  value       = module.filestore.nfs_ip
}

output "filestore_nfs_path" {
  description = "Filestore NFS export path"
  value       = module.filestore.nfs_path
}

output "filestore_instance_name" {
  description = "Filestore instance name"
  value       = module.filestore.instance_name
}

output "gke_service_account_email" {
  description = "GKE Node Service Account email (used for Workload Identity binding)"
  value       = module.gke.gke_service_account_email
}

output "sql_connection_name" {
  description = "Cloud SQL instance connection name (used for Cloud SQL Proxy)"
  value       = module.cloud-sql.sql_connection_name
}
