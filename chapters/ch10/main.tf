# chapters/ch10/main.tf
# A tiny config whose only job is to give you a state file
# worth reading: a bucket, and a setting on that bucket
# that depends on it.

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
      Chapter   = "10"
      ManagedBy = "terraform"
    }
  }
}

variable "bucket_name" {
  description = "S3 bucket names are globally unique."
  type        = string
}

variable "purpose" {
  description = "Value for the bucket's Purpose tag"
  type        = string
  default     = "state-lab"
}

resource "aws_s3_bucket" "lab" {
  bucket        = var.bucket_name
  force_destroy = true

  tags = {
    Purpose = var.purpose
  }
}

resource "aws_s3_bucket_versioning" "lab" {
  bucket = aws_s3_bucket.lab.id

  versioning_configuration {
    status = "Enabled"
  }
}
