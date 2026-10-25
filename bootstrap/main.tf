# bootstrap/main.tf
# Creates the S3 bucket that stores Terraform state for the
# rest of the book (Chapter 11). This folder keeps its own
# state locally: it is the one thing that cannot store its
# state in a bucket that does not exist yet.

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
      Chapter   = "11"
      Project   = "shortener"
      ManagedBy = "terraform"
    }
  }
}

variable "bucket_name" {
  description = "State bucket name. S3 names are globally unique."
  type        = string
}

resource "aws_s3_bucket" "state" {
  bucket = var.bucket_name

  # State is precious. Chapter 21 removes this line on purpose
  # when you tear everything down.
  lifecycle {
    prevent_destroy = true
  }
}

# Versioning keeps every past state file, so a bad write can
# be rolled back.
resource "aws_s3_bucket_versioning" "state" {
  bucket = aws_s3_bucket.state.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "state" {
  bucket = aws_s3_bucket.state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "state" {
  bucket                  = aws_s3_bucket.state.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Old state versions are kept for 90 days, then deleted.
resource "aws_s3_bucket_lifecycle_configuration" "state" {
  bucket = aws_s3_bucket.state.id

  rule {
    id     = "expire-old-versions"
    status = "Enabled"
    filter {}

    noncurrent_version_expiration {
      noncurrent_days = 90
    }
  }
}

output "state_bucket" {
  description = "Name of the state bucket"
  value       = aws_s3_bucket.state.bucket
}

output "backend_hcl" {
  description = "Save this as backend.hcl in the repo root"
  value       = <<-EOT
    bucket = "${aws_s3_bucket.state.bucket}"
    region = "us-east-1"
  EOT
}
