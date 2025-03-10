output "backend_endpoint" {
  description = "Backend endpoint URL"
  value       = "http://${google_compute_forwarding_rule.backend_forwarding_rule.ip_address}"
}