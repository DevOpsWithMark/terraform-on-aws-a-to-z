# chapters/ch12/modules/bucket/main.tf
# A one-resource module, just big enough to move into.

terraform {
  required_version = ">= 1.12"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

variable "name" {
  description = "Bucket name"
  type        = string
}

resource "aws_s3_bucket" "this" {
  bucket = var.name
}

output "name" {
  description = "Bucket name"
  value       = aws_s3_bucket.this.bucket
}
