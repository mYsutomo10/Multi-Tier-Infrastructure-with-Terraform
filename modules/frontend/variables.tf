variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "subnet_id" {
  description = "ID of the subnet"
  type        = string
}

variable "machine_type" {
  description = "Machine type for compute instances"
  type        = string
  default     = "e2-micro"
}

variable "instance_count" {
  description = "Number of instances in the managed instance group"
  type        = number
  default     = 2
}

variable "service_account_email" {
  description = "Service account email for frontend instances"
  type        = string
}

variable "backend_url" {
  description = "URL for the backend service"
  type        = string
}