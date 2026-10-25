# chapters/ch08/protect/main.tf
# prevent_destroy and destroy = false side by side.
terraform {
  # lifecycle destroy = false needs Terraform 1.16.
  required_version = ">= 1.16"

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
      Chapter   = "8"
      ManagedBy = "terraform"
    }
  }
}

variable "bucket_name" {
  description = "Start of both bucket names. S3 names are globally unique."
  type        = string
}

# Terraform refuses any plan that would destroy this.
resource "aws_s3_bucket" "guarded" {
  bucket = "${var.bucket_name}-guarded"

  lifecycle {
    prevent_destroy = true
  }
}

# Terraform forgets this instead of deleting it.
resource "aws_s3_bucket" "kept" {
  bucket = "${var.bucket_name}-kept"

  lifecycle {
    destroy = false
  }
}

output "buckets" {
  value = [
    aws_s3_bucket.guarded.bucket,
    aws_s3_bucket.kept.bucket,
  ]
}
