# modules/service/variables.tf

variable "name" {
  description = "Name prefix, e.g. devopswm-shortener-dev (max 26 chars)"
  type        = string

  validation {
    # ALB and target group names are limited to 32 characters.
    condition     = can(regex("^[a-z0-9-]{3,26}$", var.name))
    error_message = "Use 3-26 lowercase letters, digits, or dashes."
  }
}

variable "vpc_id" {
  description = "VPC to run in"
  type        = string
}

variable "public_subnet_ids" {
  description = "Subnets for the load balancer"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "Subnets for the ECS tasks"
  type        = list(string)
}

variable "image_tag" {
  description = "Tag of the image in the ECR repository"
  type        = string
  default     = "1.0.0"
}

variable "desired_count" {
  description = "Number of API tasks (0 until the image exists)"
  type        = number
  default     = 2
}

variable "container_port" {
  description = "Port the app listens on"
  type        = number
  default     = 3000
}

variable "cpu" {
  description = "Task CPU units (256 = 0.25 vCPU)"
  type        = number
  default     = 256
}

variable "memory" {
  description = "Task memory in MiB"
  type        = number
  default     = 512
}

variable "admin_token_version" {
  description = "Increase by 1 to generate a new admin token"
  type        = number
  default     = 1
}

variable "log_retention_days" {
  description = "How long CloudWatch keeps app logs"
  type        = number
  default     = 7
}

variable "point_in_time_recovery" {
  description = "Enable DynamoDB point-in-time recovery"
  type        = bool
  default     = false
}

variable "deletion_protection" {
  description = "Protect the DynamoDB table from deletion"
  type        = bool
  default     = false
}

variable "force_destroy" {
  description = "Allow destroy to remove images and secrets (labs)"
  type        = bool
  default     = true
}
