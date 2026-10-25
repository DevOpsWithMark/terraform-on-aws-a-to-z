# chapters/ch19/network/main.tf
# A tiny network root: one VPC and one subnet (both free).
# The ch19-app workspace reads these outputs.

terraform {
  required_version = ">= 1.12"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

# No profile or keys here: on your laptop the AWS CLI profile
# is used; in HCP Terraform, dynamic credentials are used.
provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      Chapter   = "19"
      ManagedBy = "terraform"
    }
  }
}

resource "aws_vpc" "lab" {
  cidr_block = "10.20.0.0/16"
  tags       = { Name = "devopswm-ch19" }
}

resource "aws_subnet" "lab" {
  vpc_id     = aws_vpc.lab.id
  cidr_block = "10.20.1.0/24"
  tags       = { Name = "devopswm-ch19-a" }
}

output "vpc_id" {
  value = aws_vpc.lab.id
}

output "subnet_id" {
  value = aws_subnet.lab.id
}
