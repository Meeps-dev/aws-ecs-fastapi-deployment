variable "repository_name" {
  description = "Name of the private ECR repository"
  type        = string
}

variable "force_delete" {
  description = "Allow repository deletion when it still contains images"
  type        = bool
  default     = false
}

variable "max_image_count" {
  description = "Maximum number of recent images retained"
  type        = number
  default     = 5

  validation {
    condition     = var.max_image_count >= 1
    error_message = "max_image_count must be at least 1."
  }
}

variable "untagged_expiration_days" {
  description = "Days before untagged images are expired"
  type        = number
  default     = 1

  validation {
    condition     = var.untagged_expiration_days >= 1
    error_message = "untagged_expiration_days must be at least 1."
  }
}

variable "tags" {
  description = "Tags applied to the ECR repository"
  type        = map(string)
  default     = {}
}
