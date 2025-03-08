output "backend_address" {
  description = "The address of the backend service"
  value       = google_compute_address.backend_lb_ip.address
}

output "backend_url" {
  description = "The URL to access the backend API"
  value       = "http://${google_compute_address.backend_lb_ip.address}:8080"
}