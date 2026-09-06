output "aws_account_id" {
  description = "AWS account used by this Terraform environment"
  value       = data.aws_caller_identity.current.account_id
}

output "github_oidc_provider_arn" {
  description = "ARN of the existing GitHub Actions OIDC provider"
  value       = data.aws_iam_openid_connect_provider.github.arn
}

output "github_oidc_subject" {
  description = "Exact GitHub OIDC subject trusted by the deployment role"
  value       = local.github_oidc_subject
}

output "github_deploy_role_name" {
  description = "Name of the repository-scoped GitHub deployment role"
  value       = aws_iam_role.github_deploy.name
}

output "github_deploy_role_arn" {
  description = "ARN of the repository-scoped GitHub deployment role"
  value       = aws_iam_role.github_deploy.arn
}

output "github_plan_role_name" {
  description = "Name of the main-branch Terraform plan role"
  value       = aws_iam_role.github_plan.name
}

output "github_plan_role_arn" {
  description = "ARN of the main-branch Terraform plan role"
  value       = aws_iam_role.github_plan.arn
}

output "vpc_id" {
  description = "ID of the Week 13 VPC"
  value       = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  description = "CIDR block of the Week 13 VPC"
  value       = module.vpc.vpc_cidr_block
}

output "availability_zones" {
  description = "Availability Zones used by the VPC"
  value       = module.vpc.availability_zones
}

output "public_subnet_ids" {
  description = "Public subnet IDs used by the future ALB and Fargate service"
  value       = module.vpc.public_subnet_ids
}

output "private_db_subnet_ids" {
  description = "Private subnet IDs used by the future RDS subnet group"
  value       = module.vpc.private_db_subnet_ids
}

output "internet_gateway_id" {
  description = "Internet Gateway attached to the VPC"
  value       = module.vpc.internet_gateway_id
}

output "public_route_table_id" {
  description = "Public route table ID"
  value       = module.vpc.public_route_table_id
}

output "private_db_route_table_id" {
  description = "Private database route table ID"
  value       = module.vpc.private_db_route_table_id
}

output "alb_security_group_id" {
  description = "ALB security group ID"
  value       = module.security.alb_security_group_id
}

output "ecs_security_group_id" {
  description = "ECS task security group ID"
  value       = module.security.ecs_security_group_id
}

output "rds_security_group_id" {
  description = "RDS security group ID"
  value       = module.security.rds_security_group_id
}

output "ecr_repository_name" {
  description = "Name of the Week 13 ECR repository"
  value       = module.ecr.repository_name
}

output "ecr_repository_arn" {
  description = "ARN of the Week 13 ECR repository"
  value       = module.ecr.repository_arn
}

output "ecr_repository_url" {
  description = "URL used when pushing the FastAPI image"
  value       = module.ecr.repository_url
}

output "ecr_registry_id" {
  description = "AWS registry ID containing the repository"
  value       = module.ecr.registry_id
}

output "rds_instance_identifier" {
  description = "Private PostgreSQL RDS instance identifier"
  value       = module.rds.db_instance_identifier
}

output "rds_subnet_group_name" {
  description = "Private RDS DB subnet group"
  value       = module.rds.db_subnet_group_name
}

output "rds_address" {
  description = "Private RDS endpoint address"
  value       = module.rds.db_address
}

output "rds_port" {
  description = "PostgreSQL listener port"
  value       = module.rds.db_port
}

output "rds_database_name" {
  description = "Application database name"
  value       = module.rds.db_name
}

output "rds_username" {
  description = "PostgreSQL master username"
  value       = module.rds.db_username
}

output "rds_engine_version" {
  description = "Actual PostgreSQL engine version"
  value       = module.rds.engine_version
}

output "rds_publicly_accessible" {
  description = "Whether the RDS instance has public access"
  value       = module.rds.publicly_accessible
}

output "database_url_parameter_name" {
  description = "SSM parameter injected into ECS as DATABASE_URL"
  value       = module.rds.database_url_parameter_name
}

output "database_url_parameter_arn" {
  description = "ARN injected into ECS as DATABASE_URL"
  value       = module.rds.database_url_parameter_arn
}

output "db_password_parameter_arn" {
  description = "Administrative DB password parameter; do not grant this directly to the application task"
  value       = module.rds.db_password_parameter_arn
}

output "application_secret_parameter_arns" {
  description = "Application SSM parameters that the future ECS execution role may retrieve"

  value = {
    SECRET_KEY = aws_ssm_parameter.application_secret_key.arn
  }
}

output "ecs_cluster_name" {
  description = "ecs cluster name"

  value = module.ecs.cluster_name
}

output "ecs_cluster_arn" {
  description = "ecs cluster arn"

  value = module.ecs.cluster_arn
}

output "ecs_task_definition_arn" {
  description = "ecs task definition family arn"

  value = module.ecs.task_definition_arn
}

output "ecs_task_definition_revision" {
  description = "ecs task definition revision"

  value = module.ecs.task_definition_revision
}

output "ecs_execution_role_name" {
  description = "ecs execution role name"

  value = module.ecs.execution_role_name
}

output "ecs_execution_role_arn" {
  description = "ecs execution role arn"

  value = module.ecs.execution_role_arn
}

output "ecs_task_role_name" {
  description = "ecs fastapi application task role name"

  value = module.ecs.task_role_name
}

output "ecs_task_role_arn" {
  description = "ecs fastapi application task role arn"

  value = module.ecs.task_role_arn
}

output "ecs_log_group_name" {
  description = "ecs cloudwatch log group name"

  value = module.ecs.log_group_name
}

output "ecs_container_name" {
  description = "ecs container name"

  value = module.ecs.container_name
}

output "alb_arn" {
  description = "ARN of the public Application Load Balancer"
  value       = module.alb.load_balancer_arn
}

output "alb_dns_name" {
  description = "Public DNS name of the Application Load Balancer"
  value       = module.alb.load_balancer_dns_name
}

output "alb_url" {
  description = "HTTP URL of the development Application Load Balancer"
  value       = "http://${module.alb.load_balancer_dns_name}"
}

output "alb_listener_arn" {
  description = "ARN of the HTTP listener"
  value       = module.alb.listener_arn
}

output "alb_target_group_arn" {
  description = "ARN of the ECS IP target group"
  value       = module.alb.target_group_arn
}

output "alb_target_group_name" {
  description = "Name of the ECS IP target group"
  value       = module.alb.target_group_name
}

output "ecs_service_name" {
  description = "Name of the FastAPI ECS service"
  value       = aws_ecs_service.api.name
}

output "ecs_service_arn" {
  description = "ARN of the FastAPI ECS service"
  value       = aws_ecs_service.api.id
}

output "ecs_service_desired_count" {
  description = "Number of FastAPI tasks maintained by the service"
  value       = aws_ecs_service.api.desired_count
}
