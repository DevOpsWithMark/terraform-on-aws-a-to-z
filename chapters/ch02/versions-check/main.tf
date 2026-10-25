# chapters/ch02/versions-check/main.tf
# Proves Terraform can reach AWS with your lab profile.
# It only reads data. It creates nothing.

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
      Chapter   = "2"
      ManagedBy = "terraform"
    }
  }
}

# Asks AWS "who am I?" -- the same call as
# aws sts get-caller-identity.
data "aws_caller_identity" "current" {}

output "account_id" {
  value = data.aws_caller_identity.current.account_id
}

# The last part of the ARN: your user or session name.
output "signed_in_as" {
  value = regex("[^/]+$", data.aws_caller_identity.current.arn)
}
