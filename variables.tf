variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP region to deploy resources"
  type        = string
  default     = "asia-southeast2"
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "vpc_name" {
  description = "Name of the VPC network"
  type        = string
  default     = "multi-tier-vpc"
}

variable "subnet_cidr" {
  description = "CIDR range for the subnet"
  type        = string
  default     = "10.0.0.0/16"
}

variable "frontend_machine_type" {
  description = "Machine type for frontend instances"
  type        = string
  default     = "e2-micro"
}

variable "backend_machine_type" {
  description = "Machine type for backend instances"
  type        = string
  default     = "e2-micro"
}

variable "db_tier" {
  description = "Database tier"
  type        = string
  default     = "db-f1-micro"
}

variable "frontend_instance_count" {
  description = "Number of frontend instances"
  type        = number
  default     = 2
}

variable "backend_instance_count" {
  description = "Number of backend instances"
  type        = number
  default     = 2
}