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

variable "postgres_major_version" {
  description = "PostgreSQL major version used by the RDS instance"
  type        = string
  default     = "15"

  validation {
    condition     = can(regex("^[0-9]+$", var.postgres_major_version))
    error_message = "postgres_major_version must contain only numbers."
  }
}

variable "db_instance_class" {
  description = "RDS instance class used by the development database"
  type        = string
  default     = "db.t4g.micro"

  validation {
    condition     = startswith(var.db_instance_class, "db.")
    error_message = "db_instance_class must begin with db."
  }
}

variable "db_allocated_storage" {
  description = "Initial PostgreSQL storage allocation in GiB"
  type        = number
  default     = 20

  validation {
    condition     = var.db_allocated_storage >= 20
    error_message = "db_allocated_storage must be at least 20 GiB."
  }
}

variable "db_name" {
  description = "Initial PostgreSQL application database"
  type        = string
  default     = "users_posts_db"

  validation {
    condition     = can(regex("^[A-Za-z][A-Za-z0-9_]{0,62}$", var.db_name))
    error_message = "db_name must begin with a letter and contain at most 63 letters, numbers, or underscores."
  }
}

variable "db_username" {
  description = "PostgreSQL master username"
  type        = string
  default     = "appadmin"

  validation {
    condition     = can(regex("^[A-Za-z][A-Za-z0-9_]{0,15}$", var.db_username))
    error_message = "db_username must begin with a letter and contain at most 16 letters, numbers, or underscores."
  }
}

variable "db_backup_retention_days" {
  description = "Number of days that automated RDS backups are retained"
  type        = number
  default     = 1

  validation {
    condition = (
      var.db_backup_retention_days >= 0 &&
      var.db_backup_retention_days <= 35
    )

    error_message = "db_backup_retention_days must be between 0 and 35."
  }
}

variable "db_password_version" {
  description = "Version trigger used when rotating the database password"
  type        = number
  default     = 1

  validation {
    condition     = var.db_password_version >= 1
    error_message = "db_password_version must be at least 1."
  }
}

variable "database_url_version" {
  description = "Version trigger used when rebuilding the DATABASE_URL parameter"
  type        = number
  default     = 1

  validation {
    condition     = var.database_url_version >= 1
    error_message = "database_url_version must be at least 1."
  }
}

variable "application_secret_version" {
  description = "Version trigger used when rotating application SecureString parameters"
  type        = number
  default     = 1

  validation {
    condition     = var.application_secret_version >= 1
    error_message = "application_secret_version must be at least 1."
  }
}

variable "ecs_image_digest" {
  description = "Verified digest of the application image in the Week 13 ECR repository"
  type        = string

  validation {
    condition     = can(regex("^sha256:[0-9a-f]{64}$", var.ecs_image_digest))
    error_message = "ecs_image_digest must be sha256 followed by 64 lowercase hexadecimal characters."
  }
}

