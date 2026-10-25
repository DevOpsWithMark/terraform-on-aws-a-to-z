# chapters/ch20/05-version-conflict/main.tf
# BROKEN ON PURPOSE: the root wants AWS provider 6.x, the
# local module pins 5.x. No version satisfies both.

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

module "legacy_bucket" {
  source = "./modules/legacy-bucket"
}
