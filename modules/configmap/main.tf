// Create the GCP secret to hold the configuration data.
resource "google_secret_manager_secret" "this" {
  secret_id = var.name
  replication {
    auto {}
  }
}

// Only the service account as which the service runs should have access to the secret.
resource "google_secret_manager_secret_iam_binding" "authorize-access" {
  secret_id = google_secret_manager_secret.this.id
  role      = "roles/secretmanager.secretAccessor"
  members   = ["serviceAccount:${var.service-account}"]
}

// Load the specified data into the secret.
resource "google_secret_manager_secret_version" "data" {
  secret      = google_secret_manager_secret.this.name
  secret_data = var.data
  // Keep older versions of the secret, so that services can pin to specific versions,
  // but still roll back in the event of an issue.
  deletion_policy = "ABANDON"
}

// Get a project number for this project ID.
data "google_project" "project" { project_id = var.project_id }

// What identity is deploying this?
data "google_client_openid_userinfo" "me" {}

