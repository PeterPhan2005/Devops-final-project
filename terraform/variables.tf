variable "project_id" {
  description = "Google Cloud Project ID"
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{4,28}[a-z0-9]$", var.project_id)) && !contains(["my first project", "my-first-project", "test", "example"], lower(var.project_id))
    error_message = "The project_id must be a valid GCP project ID (6-30 lowercase letters, digits, or hyphens, start with letter, end with letter or digit) and cannot be a placeholder value like 'My First Project', 'test', or 'example'."
  }
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
