variable "name_prefix" {
  description = "Prefix used when naming VPC resources"
  type        = string
}

variable "vpc_cidr" {
  description = "IPv4 CIDR block assigned to the VPC"
  type        = string

  validation {
    condition     = can(cidrnetmask(var.vpc_cidr))
    error_message = "vpc_cidr must be a valid IPv4 CIDR block."
  }
}

variable "availability_zones" {
  description = "Two Availability Zones used by the development environment"
  type        = list(string)

  validation {
    condition = (
      length(var.availability_zones) == 2 &&
      length(distinct(var.availability_zones)) == 2
    )

    error_message = "Exactly two different Availability Zones must be supplied."
  }
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for the two public subnets"
  type        = list(string)

  validation {
    condition = (
      length(var.public_subnet_cidrs) == 2 &&
      alltrue([
        for cidr in var.public_subnet_cidrs :
        can(cidrnetmask(cidr))
      ])
    )

    error_message = "Exactly two valid public subnet CIDR blocks are required."
  }
}

variable "private_db_subnet_cidrs" {
  description = "CIDR blocks for the two private database subnets"
  type        = list(string)

  validation {
    condition = (
      length(var.private_db_subnet_cidrs) == 2 &&
      alltrue([
        for cidr in var.private_db_subnet_cidrs :
        can(cidrnetmask(cidr))
      ])
    )

    error_message = "Exactly two valid private database subnet CIDR blocks are required."
  }
}

variable "tags" {
  description = "Tags applied to resources created by this module"
  type        = map(string)
  default     = {}
}
