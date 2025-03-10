output "db_instance_name" {
  description = "Database instance name"
  value       = google_sql_database_instance.postgres.name
}

output "db_instance_ip" {
  description = "Database instance IP"
  value       = google_sql_database_instance.postgres.private_ip_address
}

output "db_name" {
  description = "Database name"
  value       = google_sql_database.database.name
}

output "connection_string" {
  description = "Database connection string"
  value       = "postgresql://${google_sql_user.user.name}:${random_password.db_password.result}@${google_sql_database_instance.postgres.private_ip_address}:5432/${google_sql_database.database.name}"
  sensitive   = true
}