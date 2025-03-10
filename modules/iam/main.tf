resource "google_service_account" "frontend_service_account" {
  account_id   = "frontend-sa-${var.environment}"
  display_name = "Frontend Service Account for ${var.environment}"
  description  = "Service account for frontend instances in ${var.environment} environment"
}

# Create a service account for the backend
resource "google_service_account" "backend_service_account" {
  account_id   = "backend-sa-${var.environment}"
  display_name = "Backend Service Account for ${var.environment}"
  description  = "Service account for backend instances in ${var.environment} environment"
}

# Grant necessary roles to the frontend service account
resource "google_project_iam_member" "frontend_roles" {
  for_each = toset([
    "roles/monitoring.metricWriter",      # Write metrics
    "roles/logging.logWriter",            # Write logs
    "roles/compute.networkUser"           # Access to network resources
  ])
  
  project = var.project_id
  role    = each.key
  member  = "serviceAccount:${google_service_account.frontend_service_account.email}"
}

# Grant necessary roles to the backend service account
resource "google_project_iam_member" "backend_roles" {
  for_each = toset([
    "roles/monitoring.metricWriter",      # Write metrics
    "roles/logging.logWriter",            # Write logs
    "roles/compute.networkUser",          # Access to network resources
    "roles/secretmanager.secretAccessor"  # Access to secrets
  ])
  
  project = var.project_id
  role    = each.key
  member  = "serviceAccount:${google_service_account.backend_service_account.email}"
}