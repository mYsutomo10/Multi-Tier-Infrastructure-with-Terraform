# Create instance template for backend
resource "google_compute_instance_template" "backend_template" {
  name_prefix  = "${var.environment}-backend-template-"
  machine_type = var.instance_type
  tags         = ["backend"]

  disk {
    source_image = "debian-cloud/debian-11"
    auto_delete  = true
    boot         = true
    disk_size_gb = 20
  }

  network_interface {
    network    = var.vpc_network
    subnetwork = var.vpc_subnetwork
  }

  metadata_startup_script = <<-EOF
    #!/bin/bash
    apt-get update
    apt-get install -y openjdk-11-jdk
    apt-get install -y maven
    
    # Create a simple Spring Boot app
    mkdir -p /app/src/main/java/com/example/demo
    
    # Create pom.xml
    cat > /app/pom.xml << 'EOL'
    <?xml version="1.0" encoding="UTF-8"?>
    <project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
      xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 https://maven.apache.org/xsd/maven-4.0.0.xsd">
      <modelVersion>4.0.0</modelVersion>
      <parent>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-parent</artifactId>
        <version>2.7.5</version>
      </parent>
      <groupId>com.example</groupId>
      <artifactId>demo</artifactId>
      <version>0.0.1-SNAPSHOT</version>
      <name>demo</name>
      <description>Demo project for Spring Boot</description>
      <properties>
        <java.version>11</java.version>
      </properties>
      <dependencies>
        <dependency>
          <groupId>org.springframework.boot</groupId>
          <artifactId>spring-boot-starter-web</artifactId>
        </dependency>
        <dependency>
          <groupId>org.springframework.boot</groupId>
          <artifactId>spring-boot-starter-jdbc</artifactId>
        </dependency>
        <dependency>
          <groupId>org.postgresql</groupId>
          <artifactId>postgresql</artifactId>
          <scope>runtime</scope>
        </dependency>
      </dependencies>
      <build>
        <plugins>
          <plugin>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-maven-plugin</artifactId>
          </plugin>
        </plugins>
      </build>
    </project>
    EOL
    
    # Create application.properties
    mkdir -p /app/src/main/resources
    cat > /app/src/main/resources/application.properties << EOL
    server.port=8080
    spring.datasource.url=jdbc:postgresql:///${var.db_connection_name}
    spring.datasource.username=postgres
    spring.datasource.password=postgres
    spring.datasource.driver-class-name=org.postgresql.Driver
    EOL
    
    # Create main application class
    cat > /app/src/main/java/com/example/demo/DemoApplication.java << 'EOL'
    package com.example.demo;
    
    import org.springframework.boot.SpringApplication;
    import org.springframework.boot.autoconfigure.SpringBootApplication;
    
    @SpringBootApplication
    public class DemoApplication {
      public static void main(String[] args) {
        SpringApplication.run(DemoApplication.class, args);
      }
    }
    EOL
    
    # Create a simple controller
    cat > /app/src/main/java/com/example/demo/Controller.java << 'EOL'
    package com.example.demo;
    
    import org.springframework.web.bind.annotation.GetMapping;
    import org.springframework.web.bind.annotation.RestController;
    import java.util.HashMap;
    import java.util.Map;
    
    @RestController
    public class Controller {
      @GetMapping("/api/status")
      public Map<String, String> status() {
        Map<String, String> response = new HashMap<>();
        response.put("status", "OK");
        response.put("tier", "Backend");
        return response;
      }
    }
    EOL
    
    # Build and run the application
    cd /app
    mvn package -DskipTests
    java -jar target/demo-0.0.1-SNAPSHOT.jar > /app/application.log 2>&1 &
  EOF

  lifecycle {
    create_before_destroy = true
  }

  service_account {
    scopes = ["cloud-platform"]
  }
}

# Create health check
resource "google_compute_health_check" "backend_health_check" {
  name                = "${var.environment}-backend-health-check"
  check_interval_sec  = 5
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 10

  http_health_check {
    request_path = "/api/status"
    port         = "8080"
  }
}

# Create instance group manager
resource "google_compute_region_instance_group_manager" "backend_group" {
  name               = "${var.environment}-backend-group"
  base_instance_name = "${var.environment}-backend"
  region             = var.region
  
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

# Create autoscaler
resource "google_compute_region_autoscaler" "backend_autoscaler" {
  name   = "${var.environment}-backend-autoscaler"
  region = var.region
  target = google_compute_region_instance_group_manager.backend_group.id

  autoscaling_policy {
    max_replicas    = var.max_instances
    min_replicas    = var.min_instances
    cooldown_period = 60

    cpu_utilization {
      target = 0.7
    }
  }
}

# Create internal load balancer
resource "google_compute_address" "backend_lb_ip" {
  name         = "${var.environment}-backend-lb-ip"
  subnetwork   = var.vpc_subnetwork
  address_type = "INTERNAL"
  region       = var.region
}

resource "google_compute_forwarding_rule" "backend_forwarding_rule" {
  name                  = "${var.environment}-backend-forwarding-rule"
  region                = var.region
  load_balancing_scheme = "INTERNAL"
  backend_service       = google_compute_region_backend_service.backend_service.id
  all_ports             = false
  ports                 = ["8080"]
  network               = var.vpc_network
  subnetwork            = var.vpc_subnetwork
  ip_address            = google_compute_address.backend_lb_ip.address
}

resource "google_compute_region_backend_service" "backend_service" {
  name                  = "${var.environment}-backend-service"
  region                = var.region
  protocol              = "TCP"
  load_balancing_scheme = "INTERNAL"
  health_checks         = [google_compute_health_check.backend_health_check.id]

  backend {
    group           = google_compute_region_instance_group_manager.backend_group.instance_group
    balancing_mode  = "CONNECTION"
  }
}