terraform {
  backend "gcs" {
    bucket = "YOUR_TERRAFORM_STATE_BUCKET"
    prefix = "terraform/state/prod"
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
  environment = "prod"
  
  # Production-specific configurations
  frontend_instance_count = 3
  backend_instance_count  = 3
  
  # Use more powerful machine types for production
  frontend_machine_type = "e2-standard-2"
  backend_machine_type  = "e2-standard-2"
  db_tier               = "db-custom-2-4096" # 2 vCPUs, 4GB RAM
}