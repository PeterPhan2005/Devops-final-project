variable "project_id" {
  description = "Google Cloud Project ID"
  type        = string
  default     = "My First Project"
}

variable "gcp_region" {
  description = "Google Cloud Region"
  type        = string
  default     = "us-central1"
}

variable "gcp_zone" {
  description = "Google Cloud Zone"
  type        = string
  default     = "us-central1-a"
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "doc-system"
}

variable "environment" {
  description = "Environment"
  type        = string
  default     = "prod"
}

variable "db_password" {
  description = "Cloud SQL PostgreSQL password"
  type        = string
  sensitive   = true
}

variable "db_username" {
  description = "Cloud SQL PostgreSQL username"
  type        = string
  default     = "docuser"
}

variable "db_name" {
  description = "Cloud SQL database name"
  type        = string
  default     = "docdb"
}
