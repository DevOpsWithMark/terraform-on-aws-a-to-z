# chapters/ch12/versions.tf
# State lives in the S3 bucket from Chapter 11:
#   terraform init -backend-config=../../backend.hcl

terraform {
  required_version = ">= 1.12"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  backend "s3" {
    key          = "chapters/ch12/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}

provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      Chapter   = "12"
      ManagedBy = "terraform"
    }
  }
}
