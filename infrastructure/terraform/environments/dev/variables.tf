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

variable "vpc_cidr" {
  description = "CIDR block assigned to the Week 13 VPC"
  type        = string
  default     = "10.13.0.0/16"
}

variable "availability_zones" {
  description = "Two Availability Zones used by Week 13"
  type        = list(string)

  default = [
    "eu-west-2a",
    "eu-west-2b"
  ]
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for the two public subnets"
  type        = list(string)

  default = [
    "10.13.0.0/24",
    "10.13.1.0/24"
  ]
}

variable "private_db_subnet_cidrs" {
  description = "CIDR blocks for the two private database subnets"
  type        = list(string)

  default = [
    "10.13.10.0/24",
    "10.13.11.0/24"
  ]
}

variable "application_port" {
  description = "Port exposed by the FastAPI application"
  type        = number
  default     = 8000
}

variable "database_port" {
  description = "PostgreSQL database port"
  type        = number
  default     = 5432
}

variable "ecr_repository_name" {
  description = "Name of the Week 13 ECR repository"
  type        = string
  default     = "aws-ecs-fastapi-deployment"
}

variable "ecr_force_delete" {
  description = "Allow ECR deletion with images during development teardown"
  type        = bool
  default     = true
}

variable "ecr_max_image_count" {
  description = "Maximum number of recent images retained in ECR"
  type        = number
  default     = 5
}

variable "ecr_untagged_expiration_days" {
  description = "Days before untagged images are expired"
  type        = number
  default     = 1
}
