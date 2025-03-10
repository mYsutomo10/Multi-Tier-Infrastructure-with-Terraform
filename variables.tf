# Variable values for Terraform deployment
project_id = "your-gcp-project-id"
region     = "asia-southeast2"
environment = "dev" # Change this to staging or prod as needed

# Default settings (can be overridden in environment-specific configurations)
vpc_name = "multi-tier-vpc"
subnet_cidr = "10.0.0.0/16"

# Instance types (use free tier eligible resources by default)
frontend_machine_type = "e2-micro"
backend_machine_type = "e2-micro"
db_tier = "db-f1-micro"

# Instance counts
frontend_instance_count = 2
backend_instance_count = 2