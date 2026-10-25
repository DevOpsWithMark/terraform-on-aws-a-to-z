# chapters/ch20/06-perpetual-diff/main.tf
# BROKEN ON PURPOSE: apply succeeds, but every plan after it
# still shows changes. Two classic causes are combined here.

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

resource "aws_security_group" "web" {
  name        = "devopswm-ch20-web"
  description = "Perpetual diff demo"
  vpc_id      = data.aws_vpc.default.id

  # Cause 1: a value that changes on every run.
  tags = {
    LastApplied = timestamp()
  }

  # Cause 2: inline rules are authoritative. This block says
  # "HTTP is the only ingress rule"...
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ...while this separate rule adds HTTPS to the same group.
# Each resource undoes the other on every apply.
resource "aws_vpc_security_group_ingress_rule" "https" {
  security_group_id = aws_security_group.web.id
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_ipv4         = "0.0.0.0/0"
}
