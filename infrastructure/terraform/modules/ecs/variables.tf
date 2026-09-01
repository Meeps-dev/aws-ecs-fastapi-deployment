variable "name_prefix" {
  description = "Prefix used for ECS and IAM resource names"
  type        = string
}

variable "aws_region" {
  description = "AWS Region containing the ECS workload"
  type        = string
}

variable "aws_account_id" {
  description = "AWS account permitted in ECS role trust policies"
  type        = string
}

variable "ecr_repository_arn" {
  description = "Only ECR repository the execution role may pull from"
  type        = string
}

variable "container_image" {
  description = "ECR image URI pinned to an immutable SHA-256 digest"
  type        = string

  validation {
    condition     = can(regex("@sha256:[0-9a-f]{64}$", var.container_image))
    error_message = "container_image must end with @sha256:<64 lowercase hexadecimal characters>."
  }
}

variable "container_name" {
  description = "Container name used by ECS and command overrides"
  type        = string
  default     = "fastapi"
}

variable "container_port" {
  description = "Port on which the application actually listens"
  type        = number
  default     = 8000

  validation {
    condition = (
      var.container_port >= 1 &&
      var.container_port <= 65535 &&
      floor(var.container_port) == var.container_port
    )
    error_message = "container_port must be an integer between 1 and 65535."
  }
}

variable "environment" {
  description = "Non-secret environment variables only"
  type        = map(string)
  default     = {}
}

variable "secret_parameter_arns" {
  description = "Environment variable names mapped to existing SSM parameter ARNs"
  type        = map(string)

  validation {
    condition = (
      length(var.secret_parameter_arns) > 0 &&
      alltrue([
        for arn in values(var.secret_parameter_arns) :
        can(regex("^arn:[^:]+:ssm:[^:]+:[0-9]{12}:parameter/", arn))
      ])
    )
    error_message = "Supply one or more SSM parameter ARNs, not decrypted secret values."
  }
}

variable "log_group_name" {
  description = "CloudWatch log group for this application"
  type        = string
}

variable "tags" {
  description = "Tags applied to module resources"
  type        = map(string)
  default     = {}
}
