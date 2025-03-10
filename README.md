# Multi-Tier Infrastructure with Terraform on GCP
This project implements a 3-tier web application infrastructure (frontend, backend, database) on Google Cloud Platform using Terraform. The infrastructure is designed with scalability, high availability, cost optimization, and security in mind.

## Architecture Overview
The architecture follows a standard 3-tier pattern:

1. **Frontend Tier**: Web servers running Nginx, deployed in a managed instance group behind a global load balancer with Cloud CDN
2. **Backend Tier**: API servers running Node.js, deployed in a managed instance group behind an internal load balancer
3. **Database Tier**: PostgreSQL database deployed as a Cloud SQL instance with private IP

![Architecture Diagram](https://storage.googleapis.com/project-image-sources/gcp-3tier.png)

## Directory Structure
```
multi-tier-terraform/
│── modules/
│   ├── vpc/             # Network configuration
│   ├── frontend/        # Frontend web servers
│   ├── backend/         # Backend API servers
│   ├── database/        # PostgreSQL database
│   ├── iam/             # IAM roles and service accounts
│   ├── security/        # Security policies and configurations
│── environments/
│   ├── dev/             # Development environment configuration
│   ├── staging/         # Staging environment configuration
│   ├── prod/            # Production environment configuration
│── main.tf              # Main configuration
│── variables.tf         # Input variables
│── outputs.tf           # Output values
│── providers.tf         # Provider configuration
│── terraform.tfvars     # Variable values
│── README.md            # Project documentation
```

## Features
### Scalability
- Managed Instance Groups with auto-scaling capabilities
- Multi-zone deployment across asia-southeast2 region
- Load balancers for traffic distribution
- Auto-resizing database storage

### High Availability
- Multi-zone deployment for all components
- Auto-healing policies for instance groups
- Health checks for load balancers
- Regional database availability option for production

### Cost Optimization
- Free tier eligible resources (e2-micro VMs, db-f1-micro database)
- Environment-specific resource allocation (minimal for dev, scaled for prod)
- CDN for frontend static content
- Private VPC connectivity to reduce egress costs

### Security
- Private VPC network with controlled access
- Dedicated service accounts with least privilege principle
- Cloud Armor Web Application Firewall
- Secrets Manager for credential storage
- OS Login for SSH access management
- Comprehensive firewall rules

## Prerequisites
- Google Cloud Platform account
- Project with billing enabled
- Terraform 1.0.0 or newer
- Google Cloud SDK (gcloud)
- Appropriate permissions to create resources in GCP

## Getting Started
### 1. Clone the repository
```bash
git clone https://github.com/mYsutomo10/Multi-Tier-Infrastructure-with-Terraform.git
cd Multi-Tier-Infrastructure-with-Terraform
```

### 2. Set up your GCP environment
```bash
gcloud auth login
gcloud config set project YOUR_PROJECT_ID
```

### 3. Create a GCS bucket for Terraform state
```bash
gsutil mb gs://YOUR_TERRAFORM_STATE_BUCKET
```

Update the backend configuration in each environment's `main.tf` file with your bucket name.

### 4. Configure your project settings
Edit the `terraform.tfvars` file to include your GCP project ID and any other customizations.

```terraform
project_id = "your-gcp-project-id"
region     = "asia-southeast2"
environment = "dev"  # Change to staging or prod as needed
```

### 5. Initialize and apply Terraform
```bash
# Choose your environment
cd environments/dev  # or staging/prod

# Initialize Terraform
terraform init

# Validate the configuration
terraform validate

# See what changes will be made
terraform plan

# Apply the changes
terraform apply
```

## Environments
The project supports multiple environments:

### Development
- Minimal resources (1 instance per tier)
- Smallest machine types (e2-micro)
- Basic database configuration (db-f1-micro)
- Standard HDD storage

### Staging
- Moderate resources (2 instances per tier)
- Medium machine types (e2-medium)
- Small database (db-g1-small)
- Standard disk configurations

### Production
- Robust resources (3+ instances per tier)
- Standard machine types (e2-standard-2)
- Custom database configuration (db-custom-2-4096)
- SSD storage
- Regional database availability
- Full backup and recovery options

## Usage
After deployment, you can access your application through the Frontend URL, which is output at the end of the Terraform apply process.

### Accessing the application
```bash
# Get the frontend URL
terraform output frontend_url
```

### Scaling the application
To scale the application, adjust the instance counts in the environment-specific variables:

```terraform
# In environments/[env]/main.tf
frontend_instance_count = 3
backend_instance_count  = 3
```

### Adding custom configurations
To customize the application further, you can modify the modules or add new modules as needed.

### Destroying the infrastructure
```bash
# Destroy all resources
cd environments/[env]
terraform destroy
```
> **Warning**: This will destroy all resources created by this Terraform configuration.