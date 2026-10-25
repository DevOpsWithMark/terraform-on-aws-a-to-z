# chapters/ch20/01-bad-reference/main.tf
# BROKEN ON PURPOSE: one reference points at a resource name
# that does not exist. Run terraform validate to see it.

terraform {
  required_version = ">= 1.12"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      Chapter   = "20"
      ManagedBy = "terraform"
    }
  }
}

resource "aws_s3_bucket" "log" {
  bucket = "<your bucket name>" # e.g. devopswm-labs-ch20-logs
}

resource "aws_s3_bucket_versioning" "log" {
  bucket = aws_s3_bucket.logs.id

  versioning_configuration {
    status = "Enabled"
  }
}
