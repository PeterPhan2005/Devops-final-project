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
