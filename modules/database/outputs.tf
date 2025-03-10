output "connection_name" {
  description = "The connection name of the master instance to be used in connection strings"
  value       = google_sql_database_instance.postgres.connection_name
}

output "db_instance_name" {
  description = "The name of the database instance"
  value       = google_sql_database_instance.postgres.name
}

output "db_name" {
  description = "The name of the database"
  value       = google_sql_database.database.name
}