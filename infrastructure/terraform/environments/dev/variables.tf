variable "aws_region" {
  description = "AWS Region used for the Week 13 development environment"
  type        = string
  default     = "eu-west-2"
}

variable "aws_account_id" {
  description = "AWS account in which Week 13 infrastructure is allowed to run"
  type        = string

  validation {
    condition     = can(regex("^[0-9]{12}$", var.aws_account_id))
    error_message = "aws_account_id must contain exactly 12 digits."
  }
}

variable "project_name" {
  description = "Workload name used in AWS resource names"
  type        = string
  default     = "aws-ecs-fastapi-deployment"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be dev, staging, or prod."
  }
}

variable "owner" {
  description = "Resource owner used in AWS tags"
  type        = string
}

variable "github_owner" {
  description = "GitHub account or organization that owns the repository"
  type        = string
}

variable "github_owner_id" {
  description = "Immutable numeric GitHub owner ID used in the OIDC subject"
  type        = string

  validation {
    condition     = can(regex("^[0-9]+$", var.github_owner_id))
    error_message = "github_owner_id must contain only numbers."
  }
}

variable "github_repository" {
  description = "GitHub repository allowed to assume the deployment role"
  type        = string
  default     = "aws-ecs-fastapi-deployment"
}

variable "github_repository_id" {
  description = "Immutable numeric GitHub repository ID used in the OIDC subject"
  type        = string

  validation {
    condition     = can(regex("^[0-9]+$", var.github_repository_id))
    error_message = "github_repository_id must contain only numbers."
  }
}

variable "github_branch" {
  description = "Git branch allowed to assume the deployment role"
  type        = string
  default     = "main"
}
