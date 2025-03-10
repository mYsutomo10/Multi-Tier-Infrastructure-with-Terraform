output "vpc_id" {
  description = "ID of the VPC"
  value       = google_compute_network.vpc.id
}

output "subnet_id" {
  description = "ID of the Subnet"
  value       = google_compute_subnetwork.subnet.id
}