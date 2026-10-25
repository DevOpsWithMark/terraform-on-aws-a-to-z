# modules/network/variables.tf

variable "name" {
  description = "Name prefix, e.g. devopswm-shortener-dev"
  type        = string
}

variable "cidr_block" {
  description = "VPC CIDR block (a /16 is expected)"
  type        = string
  default     = "10.0.0.0/16"

  validation {
    condition     = can(cidrnetmask(var.cidr_block))
    error_message = "cidr_block must be a valid CIDR, e.g. 10.0.0.0/16."
  }
}

variable "az_count" {
  description = "How many Availability Zones to use"
  type        = number
  default     = 2

  validation {
    condition     = var.az_count >= 2 && var.az_count <= 3
    error_message = "az_count must be 2 or 3."
  }
}
