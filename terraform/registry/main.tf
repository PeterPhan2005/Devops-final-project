variable "project_id" { type = string }
variable "project_name" { type = string }
variable "gcp_region" { type = string }

resource "google_artifact_registry_repository" "main" {
  project       = var.project_id
  location      = var.gcp_region
  repository_id = "${var.project_name}-repo"
  description   = "Container registry for ${var.project_name}"
  format        = "DOCKER"
}

resource "google_service_account" "artifact_sa" {
  project    = var.project_id
  account_id = "${var.project_name}-artifact-sa"
}

resource "google_artifact_registry_repository_iam_member" "artifact_reader" {
  project    = var.project_id
  location   = var.gcp_region
  repository = google_artifact_registry_repository.main.repository_id
  role       = "roles/artifactregistry.reader"
  member     = "serviceAccount:${google_service_account.artifact_sa.email}"
}

resource "google_artifact_registry_repository_iam_member" "artifact_writer" {
  project    = var.project_id
  location   = var.gcp_region
  repository = google_artifact_registry_repository.main.repository_id
  role       = "roles/artifactregistry.writer"
  member     = "serviceAccount:${google_service_account.artifact_sa.email}"
}

output "registry_url" {
  value = "${var.gcp_region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.main.repository_id}"
}
