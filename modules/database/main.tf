resource "google_compute_global_address" "private_ip_address" {
  name          = "private-ip-address-${var.environment}"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = var.vpc_id
}

# Create a private connection to the database
resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = var.vpc_id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
}

# Create a PostgreSQL database instance
resource "google_sql_database_instance" "postgres" {
  name             = "postgres-${var.environment}"
  database_version = "POSTGRES_13"
  region           = var.region
  settings {
    tier              = var.db_tier
    availability_type = var.environment == "prod" ? "REGIONAL" : "ZONAL" # Use REGIONAL for high availability in prod
    
    backup_configuration {
      enabled            = var.environment == "prod" ? true : false
      start_time         = "02:00" # 2 AM backup
      point_in_time_recovery_enabled = var.environment == "prod" ? true : false
    }
    
    maintenance_window {
      day  = 7  # Sunday
      hour = 3  # 3 AM
    }
    
    ip_configuration {
      ipv4_enabled    = false
      private_network = var.vpc_id
    }
    
    database_flags {
      name  = "max_connections"
      value = "100"
    }
    
    # Use SSD for production, HDD for dev/staging to save costs
    disk_type = var.environment == "prod" ? "PD_SSD" : "PD_HDD"
    disk_size = 10 # Minimum size
    
    # Automatic storage increase to handle growth
    disk_autoresize = true
    disk_autoresize_limit = 20
  }
  deletion_protection = var.environment == "prod" ? true : false
  depends_on = [google_service_networking_connection.private_vpc_connection]
}

# Create a database
resource "google_sql_database" "database" {
  name     = "app_db_${var.environment}"
  instance = google_sql_database_instance.postgres.name
}

# Create a database user
resource "google_sql_user" "user" {
  name     = "app_user_${var.environment}"
  instance = google_sql_database_instance.postgres.name
  password = random_password.db_password.result
}

# Generate a random password for the database user
resource "random_password" "db_password" {
  length           = 16
  special          = true
  override_special = "_%@"
}

# Store the database password in Secret Manager
resource "google_secret_manager_secret" "db_password" {
  secret_id = "db-password-${var.environment}"
  
  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret_version" "db_password" {
  secret      = google_secret_manager_secret.db_password.id
  secret_data = random_password.db_password.result
}