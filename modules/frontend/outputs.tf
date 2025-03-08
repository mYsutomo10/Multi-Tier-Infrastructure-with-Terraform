output "frontend_url" {
  description = "The URL to access the frontend application"
  value       = "http://${google_compute_global_address.frontend_lb_ip.address}"
}