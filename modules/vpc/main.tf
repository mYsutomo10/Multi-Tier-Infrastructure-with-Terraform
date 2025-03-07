resource "google_compute_network" "vpc_network" {
  name                    = "${var.environment}-network"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "frontend_subnet" {
  name          = "${var.environment}-frontend-subnet"
  ip_cidr_range = "10.0.1.0/24"
  network       = google_compute_network.vpc_network.id
  region        = var.region
}

resource "google_compute_subnetwork" "backend_subnet" {
  name          = "${var.environment}-backend-subnet"
  ip_cidr_range = "10.0.2.0/24"
  network       = google_compute_network.vpc_network.id
  region        = var.region
}

resource "google_compute_subnetwork" "database_subnet" {
  name          = "${var.environment}-database-subnet"
  ip_cidr_range = "10.0.3.0/24"
  network       = google_compute_network.vpc_network.id
  region        = var.region
}

# Firewall rule for frontend
resource "google_compute_firewall" "frontend_firewall" {
  name    = "${var.environment}-frontend-firewall"
  network = google_compute_network.vpc_network.id

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["frontend"]
}

# Firewall rule for backend
resource "google_compute_firewall" "backend_firewall" {
  name    = "${var.environment}-backend-firewall"
  network = google_compute_network.vpc_network.id

  allow {
    protocol = "tcp"
    ports    = ["8080"]
  }

  source_tags = ["frontend"]
  target_tags = ["backend"]
}

# Firewall rule for database
resource "google_compute_firewall" "database_firewall" {
  name    = "${var.environment}-database-firewall"
  network = google_compute_network.vpc_network.id

  allow {
    protocol = "tcp"
    ports    = ["5432"]
  }

  source_tags = ["backend"]
  target_tags = ["database"]
}