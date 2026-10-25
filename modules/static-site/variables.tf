# modules/static-site/variables.tf

variable "name" {
  description = "Name prefix, e.g. devopswm-shortener-dev"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9-]{3,40}$", var.name))
    error_message = "Use 3-40 lowercase letters, digits, or dashes."
  }
}

variable "bucket_name" {
  description = "Bucket name, e.g. devopswm-shortener-dev-site"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9.-]{1,61}[a-z0-9]$", var.bucket_name))
    error_message = "Use 3-63 lowercase letters, digits, dots, or dashes."
  }
}

variable "files_dir" {
  description = "Local folder whose files are uploaded to the bucket"
  type        = string
}

variable "api_origin_domain" {
  description = "Domain of an API origin (e.g. an ALB). null = none"
  type        = string
  default     = null
}

variable "api_paths" {
  description = "Path patterns CloudFront sends to the API origin"
  type        = list(string)
  default     = ["/api/*", "/r/*"]
}

variable "price_class" {
  description = "CloudFront price class"
  type        = string
  default     = "PriceClass_100"
}

variable "force_destroy" {
  description = "Allow destroy to delete a non-empty bucket (labs)"
  type        = bool
  default     = true
}
