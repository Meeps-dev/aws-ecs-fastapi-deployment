variable "name_prefix" {
  description = "Prefix used when naming security groups"
  type        = string
}

variable "vpc_id" {
  description = "VPC in which security groups are created"
  type        = string
}

variable "application_port" {
  description = "Port exposed by the FastAPI container"
  type        = number
  default     = 8000

  validation {
    condition = (
      var.application_port >= 1 &&
      var.application_port <= 65535
    )

    error_message = "application_port must be between 1 and 65535."
  }
}

variable "database_port" {
  description = "PostgreSQL database port"
  type        = number
  default     = 5432

  validation {
    condition = (
      var.database_port >= 1 &&
      var.database_port <= 65535
    )

    error_message = "database_port must be between 1 and 65535."
  }
}

variable "tags" {
  description = "Tags applied to security groups"
  type        = map(string)
  default     = {}
}
