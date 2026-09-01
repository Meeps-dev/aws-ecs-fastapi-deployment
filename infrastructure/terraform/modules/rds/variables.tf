variable "name_prefix" {
  description = "Prefix used when naming RDS resources"
  type        = string
}

variable "private_db_subnet_ids" {
  description = "Private subnet IDs used by the RDS DB subnet group"
  type        = list(string)

  validation {
    condition = (
      length(var.private_db_subnet_ids) >= 2 &&
      length(distinct(var.private_db_subnet_ids)) >= 2
    )

    error_message = "At least two different private database subnets are required."
  }
}

variable "rds_security_group_id" {
  description = "Security group assigned to the RDS instance"
  type        = string
}

variable "parameter_prefix" {
  description = "SSM Parameter Store path used for database configuration"
  type        = string

  validation {
    condition     = startswith(var.parameter_prefix, "/")
    error_message = "parameter_prefix must begin with a forward slash."
  }
}

variable "postgres_major_version" {
  description = "PostgreSQL major version"
  type        = string
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
}

variable "allocated_storage" {
  description = "Allocated PostgreSQL storage in GiB"
  type        = number
}

variable "db_name" {
  description = "Initial application database name"
  type        = string
}

variable "db_username" {
  description = "PostgreSQL master username"
  type        = string
}

variable "backup_retention_days" {
  description = "Automated backup retention period"
  type        = number
}

variable "db_password_version" {
  description = "Database-password rotation version"
  type        = number
}

variable "database_url_version" {
  description = "DATABASE_URL parameter version"
  type        = number
}

variable "tags" {
  description = "Tags applied to RDS and SSM resources"
  type        = map(string)
  default     = {}
}
