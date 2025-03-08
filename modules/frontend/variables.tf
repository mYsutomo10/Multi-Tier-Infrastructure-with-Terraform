variable "project_id" {
  description = "The ID of the GCP project"
  type        = string
}

variable "region" {
  description = "The region to deploy resources"
  type        = string
}

variable "zone" {
  description = "The zone to deploy resources"
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

variable "vpc_subnetwork" {
  description = "The VPC subnetwork name"
  type        = string
}

variable "instance_type" {
  description = "Instance type for frontend servers"
  type        = string
}

variable "min_instances" {
  description = "Minimum number of instances in the autoscaling group"
  type        = number
}

variable "max_instances" {
  description = "Maximum number of instances in the autoscaling group"
  type        = number
}

variable "backend_address" {
  description = "The address of the backend service"
  type        = string
}