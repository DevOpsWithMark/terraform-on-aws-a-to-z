# chapters/ch20/02-cycle/main.tf
# BROKEN ON PURPOSE: two security groups whose inline rules
# point at each other. Neither can be created first.

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

data "aws_vpc" "default" {
  default = true
}

resource "aws_security_group" "app" {
  name   = "devopswm-ch20-app"
  vpc_id = data.aws_vpc.default.id

  egress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.db.id]
  }
}

resource "aws_security_group" "db" {
  name   = "devopswm-ch20-db"
  vpc_id = data.aws_vpc.default.id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.app.id]
  }
}
