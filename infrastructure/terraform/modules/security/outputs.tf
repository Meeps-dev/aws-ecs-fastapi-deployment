output "alb_security_group_id" {
  description = "Security group assigned to the future ALB"
  value       = aws_security_group.alb.id
}

output "ecs_security_group_id" {
  description = "Security group assigned to ECS task ENIs"
  value       = aws_security_group.ecs.id
}

output "rds_security_group_id" {
  description = "Security group assigned to private RDS"
  value       = aws_security_group.rds.id
}
