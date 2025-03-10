terraform {
  backend "gcs" {
    bucket = "YOUR_TERRAFORM_STATE_BUCKET"
    prefix = "terraform/state/dev"
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
  environment = "dev"
  
  # Development-specific configurations
  frontend_instance_count = 1
  backend_instance_count  = 1
  
  # Use smallest machine types for dev
  frontend_machine_type = "e2-micro"
  backend_machine_type  = "e2-micro"
  db_tier               = "db-f1-micro"
}