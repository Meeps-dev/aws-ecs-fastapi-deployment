output "repository_name" {
  description = "Name of the ECR repository"
  value       = aws_ecr_repository.this.name
}

output "repository_arn" {
  description = "ARN of the ECR repository"
  value       = aws_ecr_repository.this.arn
}

output "repository_url" {
  description = "URL used when tagging and pushing images"
  value       = aws_ecr_repository.this.repository_url
}

output "registry_id" {
  description = "AWS registry ID containing the repository"
  value       = aws_ecr_repository.this.registry_id
}
