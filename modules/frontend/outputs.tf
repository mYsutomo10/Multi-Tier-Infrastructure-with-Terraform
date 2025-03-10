output "frontend_url" {
  description = "Frontend URL"
  value       = "http://${google_compute_global_forwarding_rule.frontend_forwarding_rule.ip_address}"
}