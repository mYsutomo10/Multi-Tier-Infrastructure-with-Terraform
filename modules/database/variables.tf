variable "project_id" {
  description = "The ID of the GCP project"
  type        = string
}

variable "region" {
  description = "The region to deploy resources"
  type        = string
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
}

variable "vpc_network" {
  description = "The VPC network name"
  type        = string
}

variable "db_tier" {
  description = "The machine type for Cloud SQL instance"
  type        = string
}