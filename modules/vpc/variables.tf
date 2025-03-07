variable "project_id" {
  description = "The ID of the GCP project"
  type        = string
}

variable "region" {
  description = "The region to deploy resources"
  type        = string
  default     = "asia-southeast2"
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
}