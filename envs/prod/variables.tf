# envs/prod/variables.tf

variable "region" {
  description = "AWS Region for this environment"
  type        = string
  default     = "us-east-1"
}

variable "chapter" {
  description = "Book chapter tag (for cost tracking)"
  type        = string
  default     = "16"
}

variable "image_tag" {
  description = "App image tag in ECR"
  type        = string
  default     = "1.0.0"
}

variable "desired_count" {
  description = "API task count (set 0 before the first image push)"
  type        = number
  default     = 2
}

variable "site_bucket_name" {
  description = "Website bucket name. S3 names are globally unique."
  type        = string
}
