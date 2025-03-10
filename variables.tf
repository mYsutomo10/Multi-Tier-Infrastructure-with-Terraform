variable "project_id" {
  description = "The ID of the GCP project"
  type        = string
}

variable "credentials_file" {
  description = "Path to the GCP credentials JSON file"
  type        = string
}

variable "region" {
  description = "The region to deploy resources"
  type        = string
  default     = "asia-southeast2"
}

variable "zone" {
  description = "The zone to deploy resources"
  type        = string
  default     = "us-central1-a"
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "frontend_instance_type" {
  description = "Instance type for frontend servers"
  type        = string
  default     = "e2-medium"
}

variable "backend_instance_type" {
  description = "Instance type for backend servers"
  type        = string
  default     = "e2-medium"
}

variable "db_tier" {
  description = "The machine type for Cloud SQL instance"
  type        = string
  default     = "db-n1-standard-1"
}

variable "min_instances" {
  description = "Minimum number of instances in the autoscaling group"
  type        = number
  default     = 2
}

variable "max_instances" {
  description = "Maximum number of instances in the autoscaling group"
  type        = number
  default     = 5
}