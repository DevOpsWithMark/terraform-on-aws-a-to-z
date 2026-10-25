# chapters/ch16/workspaces-demo/main.tf
# One configuration, one state per CLI workspace (Chapter 16).

terraform {
  required_version = ">= 1.12"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  # The bucket name comes from backend.hcl (Chapter 11):
  #   terraform init -backend-config=../../../backend.hcl
  backend "s3" {
    key          = "chapters/ch16/workspaces-demo.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}

locals {
  env = terraform.workspace

  # Settings per workspace. There is no "default" entry on
  # purpose: a run in the default workspace fails early.
  settings = {
    dev  = { expire_days = 7 }
    prod = { expire_days = 30 }
  }
  cfg = local.settings[local.env]
}

provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      Chapter     = "16"
      ManagedBy   = "terraform"
      Environment = local.env
    }
  }
}

resource "aws_s3_bucket" "demo" {
  # S3 bucket names are globally unique: use your own name.
  # e.g. devopswm-labs-ch16 (the workspace name is appended)
  bucket        = "<your bucket name>-${local.env}"
  force_destroy = true
}

resource "aws_s3_bucket_lifecycle_configuration" "demo" {
  bucket = aws_s3_bucket.demo.id

  rule {
    id     = "expire-objects"
    status = "Enabled"
    filter {}

    expiration {
      days = local.cfg.expire_days
    }
  }
}
