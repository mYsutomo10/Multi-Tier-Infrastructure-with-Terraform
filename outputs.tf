output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "frontend_url" {
  description = "Frontend URL"
  value       = module.frontend.frontend_url
}

output "backend_url" {
  description = "Backend URL"
  value       = module.backend.backend_endpoint
}

output "database_connection_string" {
  description = "Database connection string (masked)"
  value       = "postgresql://<username>:<password>@${module.database.db_instance_ip}:5432/${module.database.db_name}"
  sensitive   = true
}