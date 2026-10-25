# chapters/ch08/variables.tf
variable "instance_type" {
  description = "EC2 instance type for the web server"
  type        = string
  default     = "t3.micro"

  validation {
    condition = contains(
      ["t3.micro", "t3.small"], var.instance_type
    )
    error_message = "Use t3.micro or t3.small in the labs."
  }
}

variable "ami_name_pattern" {
  description = "Name filter for the Amazon Linux 2023 AMI"
  type        = string
  default     = "al2023-ami-2023.*-x86_64"
}

variable "page_message" {
  description = "Text shown on the test page"
  type        = string
  default     = "Hello from Chapter 8"
}

variable "release" {
  description = "Bump to force a fresh server"
  type        = string
  default     = "v1"
}
