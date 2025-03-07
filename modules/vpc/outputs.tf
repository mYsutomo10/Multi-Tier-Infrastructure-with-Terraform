output "network_id" {
  description = "The ID of the VPC network"
  value       = google_compute_network.vpc_network.id
}

output "network_name" {
  description = "The name of the VPC network"
  value       = google_compute_network.vpc_network.name
}

output "frontend_subnet_name" {
  description = "The name of the frontend subnet"
  value       = google_compute_subnetwork.frontend_subnet.name
}

output "backend_subnet_name" {
  description = "The name of the backend subnet"
  value       = google_compute_subnetwork.backend_subnet.name
}

output "database_subnet_name" {
  description = "The name of the database subnet"
  value       = google_compute_subnetwork.database_subnet.name
}