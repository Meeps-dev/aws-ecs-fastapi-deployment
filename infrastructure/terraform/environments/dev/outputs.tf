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
