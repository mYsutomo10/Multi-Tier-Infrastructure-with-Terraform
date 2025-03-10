resource "google_compute_instance_template" "frontend_template" {
  name_prefix  = "frontend-template-"
  machine_type = var.machine_type
  region       = var.region

  disk {
    source_image = "debian-cloud/debian-11"
    auto_delete  = true
    boot         = true
    disk_type    = "pd-standard" # Cost-effective for dev/staging
    disk_size_gb = 10
  }

  network_interface {
    subnetwork = var.subnet_id
    
    # Using a Cloud Load Balancer, so we don't need external IPs for instances
    # Comment out if direct access is needed
    # access_config {
    #   // Ephemeral IP
    # }
  }

  metadata = {
    startup-script = <<-EOF
      #!/bin/bash
      apt-get update
      apt-get install -y nginx
      cat > /var/www/html/index.html << 'EOL'
      <!DOCTYPE html>
      <html>
      <head>
        <title>Multi-Tier App</title>
        <script>
          async function fetchBackend() {
            try {
              const response = await fetch('${var.backend_url}/api/status');
              const data = await response.json();
              document.getElementById('status').textContent = JSON.stringify(data);
            } catch (error) {
              document.getElementById('status').textContent = "Error connecting to backend";
            }
          }
        </script>
      </head>
      <body>
        <h1>Welcome to the Multi-Tier App</h1>
        <p>Backend Status: <span id="status">Loading...</span></p>
        <button onclick="fetchBackend()">Refresh Status</button>
      </body>
      </html>
      EOL
      systemctl enable nginx
      systemctl start nginx
    EOF
  }

  service_account {
    email  = var.service_account_email
    scopes = ["cloud-platform"]
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = ["frontend", "http-server", var.environment]
}

# Managed instance group for frontend servers
resource "google_compute_region_instance_group_manager" "frontend_mig" {
  name                      = "frontend-mig-${var.environment}"
  base_instance_name        = "frontend"
  region                    = var.region
  distribution_policy_zones = data.google_compute_zones.available.names
  target_size               = var.instance_count

  version {
    instance_template = google_compute_instance_template.frontend_template.id
  }

  named_port {
    name = "http"
    port = 80
  }

  auto_healing_policies {
    health_check      = google_compute_health_check.frontend_health_check.id
    initial_delay_sec = 300
  }
}

# Health check for frontend
resource "google_compute_health_check" "frontend_health_check" {
  name                = "frontend-health-check-${var.environment}"
  check_interval_sec  = 5
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 2

  http_health_check {
    port         = 80
    request_path = "/"
  }
}

# External load balancer for frontend
resource "google_compute_global_forwarding_rule" "frontend_forwarding_rule" {
  name                  = "frontend-lb-${var.environment}"
  ip_protocol           = "TCP"
  load_balancing_scheme = "EXTERNAL"
  port_range            = "80"
  target                = google_compute_target_http_proxy.frontend_http_proxy.id
}

resource "google_compute_target_http_proxy" "frontend_http_proxy" {
  name    = "frontend-http-proxy-${var.environment}"
  url_map = google_compute_url_map.frontend_url_map.id
}

resource "google_compute_url_map" "frontend_url_map" {
  name            = "frontend-url-map-${var.environment}"
  default_service = google_compute_backend_service.frontend_backend_service.id
}

resource "google_compute_backend_service" "frontend_backend_service" {
  name                  = "frontend-backend-service-${var.environment}"
  protocol              = "HTTP"
  port_name             = "http"
  timeout_sec           = 10
  enable_cdn            = true # Enable Cloud CDN for static content
  health_checks         = [google_compute_health_check.frontend_health_check.id]
  load_balancing_scheme = "EXTERNAL"

  backend {
    group = google_compute_region_instance_group_manager.frontend_mig.instance_group
  }
}

# Available zones
data "google_compute_zones" "available" {
  region = var.region
}