output "load_balancer_arn" {
  description = "ARN of the public Application Load Balancer"
  value       = aws_lb.this.arn
}

output "load_balancer_dns_name" {
  description = "Public DNS name of the Application Load Balancer"
  value       = aws_lb.this.dns_name
}

output "load_balancer_zone_id" {
  description = "Canonical hosted-zone ID of the Application Load Balancer"
  value       = aws_lb.this.zone_id
}

output "listener_arn" {
  description = "ARN of the HTTP listener"
  value       = aws_lb_listener.http.arn
}

output "target_group_arn" {
  description = "ARN of the ECS IP target group"
  value       = aws_lb_target_group.api.arn
}

output "target_group_name" {
  description = "Name of the ECS IP target group"
  value       = aws_lb_target_group.api.name
}
