output "frontend_url" {
  description = "The URL to access the frontend application"
  value       = module.frontend.frontend_url
}

output "backend_url" {
  description = "The URL to access the backend API"
  value       = module.backend.backend_url
}

output "database_connection_name" {
  description = "The connection name of the database instance"
  value       = module.database.connection_name
}

output "vpc_network" {
  description = "The VPC network name"
  value       = module.vpc.network_name
}