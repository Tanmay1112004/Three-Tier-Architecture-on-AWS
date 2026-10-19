output "application_url" {
  description = "Open this URL after both Auto Scaling groups report healthy targets."
  value       = "http://${aws_lb.frontend.dns_name}"
}

output "frontend_alb_dns_name" {
  value = aws_lb.frontend.dns_name
}

output "backend_alb_dns_name" {
  description = "Internal ALB DNS name, reachable only from the frontend tier."
  value       = aws_lb.backend.dns_name
}

output "rds_endpoint" {
  description = "Private database endpoint."
  value       = aws_db_instance.main.address
}
