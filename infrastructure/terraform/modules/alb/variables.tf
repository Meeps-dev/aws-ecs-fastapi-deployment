variable "load_balancer_name" {
  description = "Name assigned to the public Application Load Balancer"
  type        = string

  validation {
    condition = (
      length(var.load_balancer_name) >= 1 &&
      length(var.load_balancer_name) <= 32
    )

    error_message = "load_balancer_name must contain between 1 and 32 characters."
  }
}

variable "target_group_name" {
  description = "Name assigned to the FastAPI target group"
  type        = string

  validation {
    condition = (
      length(var.target_group_name) >= 1 &&
      length(var.target_group_name) <= 32
    )

    error_message = "target_group_name must contain between 1 and 32 characters."
  }
}

variable "vpc_id" {
  description = "VPC in which the target group is created"
  type        = string
}

variable "public_subnet_ids" {
  description = "Two public subnet IDs used by the Application Load Balancer"
  type        = list(string)

  validation {
    condition = (
      length(var.public_subnet_ids) == 2 &&
      length(distinct(var.public_subnet_ids)) == 2
    )

    error_message = "Exactly two different public subnet IDs are required."
  }
}

variable "alb_security_group_id" {
  description = "Security group attached to the Application Load Balancer"
  type        = string
}

variable "application_port" {
  description = "FastAPI container and target-group port"
  type        = number
  default     = 8000

  validation {
    condition = (
      var.application_port >= 1 &&
      var.application_port <= 65535 &&
      floor(var.application_port) == var.application_port
    )

    error_message = "application_port must be an integer between 1 and 65535."
  }
}

variable "health_check_path" {
  description = "Unauthenticated HTTP path used for ALB health checks"
  type        = string
  default     = "/health"

  validation {
    condition     = startswith(var.health_check_path, "/")
    error_message = "health_check_path must begin with /."
  }
}

variable "tags" {
  description = "Tags applied to ALB resources"
  type        = map(string)
  default     = {}
}
