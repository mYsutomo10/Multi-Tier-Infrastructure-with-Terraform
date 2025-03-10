resource "google_compute_firewall" "allow_http_to_frontend" {
  name    = "allow-http-to-frontend-${var.environment}"
  network = var.vpc_id
  
  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }
  
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["frontend", "http-server"]
  
  description = "Allow HTTP/HTTPS traffic to frontend instances"
}

# Firewall rule to allow internal traffic between instances
resource "google_compute_firewall" "allow_internal" {
  name    = "allow-internal-${var.environment}"
  network = var.vpc_id
  
  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }
  
  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }
  
  allow {
    protocol = "icmp"
  }
  
  source_ranges = ["10.0.0.0/8"]
  description   = "Allow internal traffic between instances"
}

# Firewall rule to allow health checks
resource "google_compute_firewall" "allow_health_checks" {
  name    = "allow-health-checks-${var.environment}"
  network = var.vpc_id
  
  allow {
    protocol = "tcp"
    ports    = ["80", "443", "8080"]
  }
  
  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"] # Google health check ranges
  target_tags   = ["frontend", "backend", "http-server", "api-server"]
  
  description = "Allow health checks to frontend and backend instances"
}

# Deny all egress to internet except for necessary services
resource "google_compute_firewall" "deny_internet_egress" {
  name               = "deny-internet-egress-${var.environment}"
  network            = var.vpc_id
  direction          = "EGRESS"
  destination_ranges = ["0.0.0.0/0"]
  
  deny {
    protocol = "all"
  }
  
  target_tags = ["backend"]
  priority    = 1000
  
  description = "Deny all egress traffic to internet from backend instances"
}

# Allow egress to Google APIs and services
resource "google_compute_firewall" "allow_google_apis_egress" {
  name               = "allow-google-apis-egress-${var.environment}"
  network            = var.vpc_id
  direction          = "EGRESS"
  destination_ranges = ["199.36.153.8/30"] # Restricted Google API access
  
  allow {
    protocol = "tcp"
    ports    = ["443"]
  }

  target_tags = ["frontend", "backend", "api-server"]
  priority    = 900
  
  description = "Allow egress traffic to Google APIs and services"
}

# Enable OS Login for SSH access management
resource "google_compute_project_metadata" "os_login" {
  metadata = {
    enable-oslogin = "TRUE"
  }
}

# Security Policy for Cloud Armor (WAF)
resource "google_compute_security_policy" "security_policy" {
  name        = "frontend-security-policy-${var.environment}"
  description = "Web Application Firewall rules for frontend"

  # Default rule (deny all)
  rule {
    action   = "deny(403)"
    priority = "2147483647"
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = ["*"]
      }
    }
    description = "Default deny rule"
  }

  # Allow rule for legitimate traffic
  rule {
    action   = "allow"
    priority = "1000"
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = ["0.0.0.0/0"]
      }
    }
    description = "Allow legitimate traffic"
  }

  # Block SQL injection attempts
  rule {
    action   = "deny(403)"
    priority = "100"
    match {
      expr {
        expression = "evaluatePreconfiguredExpr('sqli-stable')"
      }
    }
    description = "Block SQL injection attempts"
  }

  # Block XSS attempts
  rule {
    action   = "deny(403)"
    priority = "200"
    match {
      expr {
        expression = "evaluatePreconfiguredExpr('xss-stable')"
      }
    }
    description = "Block XSS attempts"
  }
}