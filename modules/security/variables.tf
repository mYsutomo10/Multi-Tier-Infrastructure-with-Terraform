variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
}