# chapters/ch03/main.tf
# Your first Terraform configuration: one tagged S3 bucket.

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
      Chapter   = "3"
      ManagedBy = "terraform"
    }
  }
}

resource "aws_s3_bucket" "lab" {
  # S3 bucket names are globally unique: no two AWS accounts can
  # share one. Replace the placeholder with your own name.
  bucket = "<your bucket name>" # e.g. devopswm-labs-ex1

  # Lets destroy delete the bucket even if it holds objects.
  # Fine for a lab; never for a bucket with real data.
  force_destroy = true

  tags = {
    Purpose = "first-apply"
  }
}
