# chapters/ch07/variables.tf
variable "bucket_name" {
  description = "Start of every bucket name (globally unique)"
  type        = string
}

variable "buckets" {
  description = "Buckets to create, keyed by short name"
  type = map(object({
    purpose    = string
    versioning = bool
  }))
}

variable "ingress_rules" {
  description = "Inbound rules for the web security group"
  type = list(object({
    description = string
    port        = number
    cidr_blocks = list(string)
  }))
  default = [
    {
      description = "HTTP from anywhere"
      port        = 80
      cidr_blocks = ["0.0.0.0/0"]
    },
  ]
}

variable "enable_logs" {
  description = "Create a log bucket and turn on access logs"
  type        = bool
  default     = false
}
