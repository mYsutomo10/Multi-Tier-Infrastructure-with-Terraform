# Create instance template for frontend
resource "google_compute_instance_template" "frontend_template" {
  name_prefix  = "${var.environment}-frontend-template-"
  machine_type = var.instance_type
  tags         = ["frontend"]

  disk {
    source_image = "debian-cloud/debian-11"
    auto_delete  = true
    boot         = true
    disk_size_gb = 20
  }

  network_interface {
    network    = var.vpc_network
    subnetwork = var.vpc_subnetwork
    access_config {
      // Ephemeral public IP
    }
  }

  metadata_startup_script = <<-EOF
    #!/bin/bash
    apt-get update
    apt-get install -y nginx
    cat > /var/www/html/index.html << 'EOL'
    <!DOCTYPE html>
    <html>
    <head>
      <title>Frontend App</title>
    </head>
    <body>
      <h1>Frontend Application</h1>
      <p>Connected to backend at: ${var.backend_address}</p>
    </body>
    </html>
    EOL
    systemctl enable nginx
    systemctl start nginx
  EOF

  lifecycle {
    create_before_destroy = true
  }
}

# Create health check
resource "google_compute_health_check" "frontend_health_check" {
  name                = "${var.environment}-frontend-health-check"
  check_interval_sec  = 5
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 10

  http_health_check {
    request_path = "/"
    port         = "80"
  }
}

# Create instance group manager
resource "google_compute_region_instance_group_manager" "frontend_group" {
  name               = "${var.environment}-frontend-group"
  base_instance_name = "${var.environment}-frontend"
  region             = var.region
  
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

# Create autoscaler
resource "google_compute_region_autoscaler" "frontend_autoscaler" {
  name   = "${var.environment}-frontend-autoscaler"
  region = var.region
  target = google_compute_region_instance_group_manager.frontend_group.id

  autoscaling_policy {
    max_replicas    = var.max_instances
    min_replicas    = var.min_instances
    cooldown_period = 60

    cpu_utilization {
      target = 0.7
    }
  }
}

# Create external load balancer
resource "google_compute_global_address" "frontend_lb_ip" {
  name = "${var.environment}-frontend-lb-ip"
}

resource "google_compute_global_forwarding_rule" "frontend_forwarding_rule" {
  name       = "${var.environment}-frontend-forwarding-rule"
  target     = google_compute_target_http_proxy.frontend_proxy.id
  port_range = "80"
  ip_address = google_compute_global_address.frontend_lb_ip.address
}

resource "google_compute_target_http_proxy" "frontend_proxy" {
  name    = "${var.environment}-frontend-proxy"
  url_map = google_compute_url_map.frontend_url_map.id
}

resource "google_compute_url_map" "frontend_url_map" {
  name            = "${var.environment}-frontend-url-map"
  default_service = google_compute_backend_service.frontend_backend_service.id
}

resource "google_compute_backend_service" "frontend_backend_service" {
  name                  = "${var.environment}-frontend-backend-service"
  protocol              = "HTTP"
  port_name             = "http"
  load_balancing_scheme = "EXTERNAL"
  timeout_sec           = 10
  health_checks         = [google_compute_health_check.frontend_health_check.id]

  backend {
    group           = google_compute_region_instance_group_manager.frontend_group.instance_group
    balancing_mode  = "UTILIZATION"
    capacity_scaler = 1.0
  }
}