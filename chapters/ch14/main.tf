# chapters/ch14/main.tf
# Builds only the network, using the same module and inputs
# that envs/dev uses in Chapter 15. Destroy it at the end.

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
      Chapter     = "14"
      Project     = "shortener"
      Environment = "dev"
      ManagedBy   = "terraform"
    }
  }
}

module "network" {
  source = "../../modules/network"

  name       = "devopswm-shortener-dev"
  cidr_block = "10.0.0.0/16"
  az_count   = 2
}
