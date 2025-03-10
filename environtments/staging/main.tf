terraform {
  backend "gcs" {
    bucket = "YOUR_TERRAFORM_STATE_BUCKET"
    prefix = "terraform/state/staging"
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

module "multi_tier_app" {
  source = "../../"
  
  project_id = var.project_id
  region     = var.region
  environment = "staging"
  
  # Staging-specific configurations
  frontend_instance_count = 2
  backend_instance_count  = 2
  
  # Use standard machine types for staging
  frontend_machine_type = "e2-medium"
  backend_machine_type  = "e2-medium"
  db_tier               = "db-g1-small"
}

# Variables for staging environment
variable "project_id" {
  description = "GCP Project ID"
  type        = string
}