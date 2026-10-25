# chapters/ch20/05-version-conflict/modules/legacy-bucket/main.tf
# An old module written for AWS provider 5.

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

resource "aws_s3_bucket" "this" {
  # e.g. devopswm-labs-ch20-legacy
  bucket = "<your bucket name>"
}

output "bucket" {
  value = aws_s3_bucket.this.bucket
}
