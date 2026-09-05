output "db_instance_identifier" {
  description = "RDS DB instance identifier"
  value       = aws_db_instance.this.identifier
}

output "db_subnet_group_name" {
  description = "RDS DB subnet group name"
  value       = aws_db_subnet_group.this.name
}

output "db_address" {
  description = "Private RDS DNS address"
  value       = aws_db_instance.this.address
}

output "db_port" {
  description = "PostgreSQL listener port"
  value       = aws_db_instance.this.port
}

output "db_name" {
  description = "Application database name"
  value       = aws_db_instance.this.db_name
}

output "db_username" {
  description = "PostgreSQL master username"
  value       = aws_db_instance.this.username
}

output "engine_version" {
  description = "Actual PostgreSQL engine version selected by AWS"
  value       = aws_db_instance.this.engine_version_actual
}

output "publicly_accessible" {
  description = "Whether the RDS instance is publicly accessible"
  value       = aws_db_instance.this.publicly_accessible
}

output "db_password_parameter_name" {
  description = "Name of the administrative database password parameter"
  value       = aws_ssm_parameter.db_password.name
}

output "db_password_parameter_arn" {
  description = "ARN of the administrative database password parameter"
  value       = aws_ssm_parameter.db_password.arn
}

output "database_url_parameter_name" {
  description = "Name of the ECS DATABASE_URL parameter"
  value       = aws_ssm_parameter.database_url.name
}

output "database_url_parameter_arn" {
  description = "ARN of the ECS DATABASE_URL parameter"
  value       = aws_ssm_parameter.database_url.arn
}
