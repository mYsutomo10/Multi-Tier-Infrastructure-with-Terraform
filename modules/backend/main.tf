resource "google_compute_instance_template" "backend_template" {
  name_prefix  = "backend-template-"
  machine_type = var.machine_type
  region       = var.region

  disk {
    source_image = "debian-cloud/debian-11"
    auto_delete  = true
    boot         = true
    disk_type    = "pd-standard"  
    disk_size_gb = 10
  }

  network_interface {
    subnetwork = var.subnet_id
    # No external IP for better security
  }

  metadata = {
    startup-script = <<-EOF
      #!/bin/bash
      apt-get update
      apt-get install -y nodejs npm
      mkdir -p /app
      cat > /app/server.js << 'EOL'
      const http = require('http');
      
      const server = http.createServer((req, res) => {
        if (req.url === '/api/status') {
          res.writeHead(200, {'Content-Type': 'application/json'});
          res.end(JSON.stringify({
            status: 'operational',
            timestamp: new Date().toISOString(),
            instance: process.env.HOSTNAME || 'unknown'
          }));
        } else {
          res.writeHead(404, {'Content-Type': 'application/json'});
          res.end(JSON.stringify({error: 'Not found'}));
        }
      });
      
      const PORT = process.env.PORT || 8080;
      server.listen(PORT, () => {
        console.log(`Server running on port ${PORT}`);
      });
      EOL
      
      cat > /etc/systemd/system/backend.service << 'EOL'
      [Unit]
      Description=Backend Node.js Service
      After=network.target
      
      [Service]
      Environment=PORT=8080
      Environment=DB_CONNECTION=${var.database_connection_string}
      Type=simple
      User=www-data
      WorkingDirectory=/app
      ExecStart=/usr/bin/node /app/server.js
      Restart=on-failure
      
      [Install]
      WantedBy=multi-user.target
      EOL
      
      systemctl enable backend
      systemctl start backend
    EOF
  }

  service_account {
    email  = var.service_account_email
    scopes = ["cloud-platform"]
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = ["backend", "api-server", var.environment]
}

# Managed instance group for backend servers
resource "google_compute_region_instance_group_manager" "backend_mig" {
  name                      = "backend-mig-${var.environment}"
  base_instance_name        = "backend"
  region                    = var.region
  distribution_policy_zones = data.google_compute_zones.available.names
  target_size               = var.instance_count

  version {
    instance_template = google_compute_instance_template.backend_template.id
  }

  named_port {
    name = "http"
    port = 8080
  }

  auto_healing_policies {
    health_check      = google_compute_health_check.backend_health_check.id
    initial_delay_sec = 300
  }
}

# Health check for backend
resource "google_compute_health_check" "backend_health_check" {
  name                = "backend-health-check-${var.environment}"
  check_interval_sec  = 5
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 2

  http_health_check {
    port         = 8080
    request_path = "/api/status"
  }
}

# Internal load balancer for backend
resource "google_compute_region_backend_service" "backend_service" {
  name                  = "backend-service-${var.environment}"
  region                = var.region
  protocol              = "HTTP"
  load_balancing_scheme = "INTERNAL_MANAGED"
  timeout_sec           = 10
  health_checks         = [google_compute_health_check.backend_health_check.id]
  
  backend {
    group = google_compute_region_instance_group_manager.backend_mig.instance_group
  }
}

resource "google_compute_region_url_map" "backend_url_map" {
  name            = "backend-url-map-${var.environment}"
  region          = var.region
  default_service = google_compute_region_backend_service.backend_service.id
}

resource "google_compute_region_target_http_proxy" "backend_http_proxy" {
  name    = "backend-http-proxy-${var.environment}"
  region  = var.region
  url_map = google_compute_region_url_map.backend_url_map.id
}

resource "google_compute_forwarding_rule" "backend_forwarding_rule" {
  name                  = "backend-forwarding-rule-${var.environment}"
  region                = var.region
  ip_protocol           = "TCP"
  load_balancing_scheme = "INTERNAL_MANAGED"
  port_range            = "80"
  target                = google_compute_region_target_http_proxy.backend_http_proxy.id
  network               = var.vpc_id
  subnetwork            = var.subnet_id
}

# Available zones
data "google_compute_zones" "available" {
  region = var.region
}