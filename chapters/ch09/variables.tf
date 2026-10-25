# chapters/ch09/variables.tf
variable "token_version" {
  description = "Increase by 1 to generate and store a new token"
  type        = number
  default     = 1
}

variable "api_key" {
  description = "Third-party API key, supplied at run time"
  type        = string
  sensitive   = true
  ephemeral   = true
}

variable "api_key_version" {
  description = "Increase by 1 after changing api_key"
  type        = number
  default     = 1
}
