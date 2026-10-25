# chapters/ch06/variables.tf

variable "environment" {
  description = "Environment name: dev or prod"
  type        = string
  # No default: you must choose one.

  validation {
    condition     = contains(["dev", "prod"], var.environment)
    error_message = "environment must be \"dev\" or \"prod\"."
  }
}

variable "instance_type" {
  description = "EC2 instance type (small, cheap types only)"
  type        = string
  default     = "t3.micro"
  nullable    = false

  validation {
    condition = contains(
      ["t3.micro", "t3.small"], var.instance_type
    )
    error_message = "Allowed types: t3.micro, t3.small."
  }
}

variable "tags" {
  description = "Extra tags for every resource in this lab"
  type        = map(string)
  default     = {}
}

variable "web" {
  description = "Web server settings"
  type = object({
    heading      = optional(string, "Hello")
    allowed_cidr = optional(string, "0.0.0.0/0")
    volume_size  = optional(number, 8)
  })
  default  = {}
  nullable = false

  validation {
    condition     = var.web.volume_size >= 8
    error_message = "volume_size must be at least 8 (GiB)."
  }
}

variable "status_token" {
  description = "Secret file name for the status page"
  type        = string
  sensitive   = true

  validation {
    condition = can(
      regex("^[a-z0-9]{8,32}$", var.status_token)
    )
    error_message = "Use 8-32 lowercase letters or digits."
  }
}
