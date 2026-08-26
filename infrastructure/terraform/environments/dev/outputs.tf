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
