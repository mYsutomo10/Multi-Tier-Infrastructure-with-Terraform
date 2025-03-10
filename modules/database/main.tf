resource "random_id" "db_name_suffix" {
  byte_length = 4
}

resource "google_sql_database_instance" "postgres" {
  name             = "${var.environment}-db-${random_id.db_name_suffix.hex}"
  database_version = "POSTGRES_14"
  region           = var.region

  settings {
    tier = var.db_tier
    
    availability_type = "ZONAL"  # Use "REGIONAL" for high availability in production
    
    ip_configuration {
      ipv4_enabled    = false
      private_network = var.vpc_network
    }
    
    backup_configuration {
      enabled    = true
      start_time = "01:00"
    }
    
    maintenance_window {
      day          = 7  # Sunday
      hour         = 3
      update_track = "stable"
    }
  }

  deletion_protection = false  # Set to true for production
}

resource "google_sql_database" "database" {
  name     = "appdb"
  instance = google_sql_database_instance.postgres.name
}

resource "google_sql_user" "postgres" {
  name     = "postgres"
  instance = google_sql_database_instance.postgres.name
  password = "postgres"  # In production, use a more secure method to manage passwords
}