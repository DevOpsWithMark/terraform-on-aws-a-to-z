# chapters/ch19/app/main.tf
# A tiny app root for a VCS-driven workspace. It reads the
# network workspace's outputs and adds a security group and an
# S3 bucket. No cloud block: HCP Terraform supplies the state
# location for VCS-driven runs.

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
      Chapter   = "19"
      ManagedBy = "terraform"
    }
  }
}

variable "hcp_organization" {
  description = "Your HCP Terraform organization name"
  type        = string
}

# Inside an HCP Terraform run, no token is needed here. The
# network workspace must share its state with this one.
data "terraform_remote_state" "network" {
  backend = "remote"

  config = {
    organization = var.hcp_organization
    workspaces = {
      name = "ch19-network"
    }
  }
}

resource "aws_security_group" "app" {
  name        = "devopswm-ch19-app"
  description = "Chapter 19 app tier (no rules)"
  vpc_id      = data.terraform_remote_state.network.outputs.vpc_id
}

resource "aws_s3_bucket" "artifacts" {
  # S3 bucket names are globally unique: use your own name.
  # e.g. devopswm-labs-ch19-artifacts
  bucket = "<your bucket name>"

  # The Chapter 19 policy denies S3 buckets without this tag.
  tags = {
    Project = "shortener"
  }
}

output "security_group_id" {
  value = aws_security_group.app.id
}

output "bucket_name" {
  value = aws_s3_bucket.artifacts.bucket
}
