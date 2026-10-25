# chapters/ch20/04-access-denied/main.tf
# BROKEN ON PURPOSE: the provider assumes a read-only role,
# then tries to create a security group. Plan works (reads
# are allowed); apply fails with an authorization error.

terraform {
  required_version = ">= 1.12"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

variable "role_arn" {
  description = "role_arn output of the setup folder"
  type        = string
}

provider "aws" {
  region = "us-east-1"

  assume_role {
    role_arn     = var.role_arn
    session_name = "devopswm-ch20"
  }

  default_tags {
    tags = {
      Chapter   = "20"
      ManagedBy = "terraform"
    }
  }
}

data "aws_vpc" "default" {
  default = true
}

resource "aws_security_group" "denied" {
  name        = "devopswm-ch20-denied"
  description = "Creation should fail: role is read-only"
  vpc_id      = data.aws_vpc.default.id
}
