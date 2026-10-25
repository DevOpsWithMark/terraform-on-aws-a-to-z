# chapters/ch20/04-access-denied/setup/main.tf
# Creates a read-only role that your admin identity can
# assume. The broken config in the parent folder uses it.

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

data "aws_caller_identity" "me" {}

locals {
  account_id   = data.aws_caller_identity.me.account_id
  account_root = "arn:aws:iam::${local.account_id}:root"
}

data "aws_iam_policy_document" "trust" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = [local.account_root]
    }
  }
}

resource "aws_iam_role" "readonly" {
  name               = "devopswm-ch20-readonly"
  assume_role_policy = data.aws_iam_policy_document.trust.json
}

resource "aws_iam_role_policy_attachment" "readonly" {
  role       = aws_iam_role.readonly.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

output "role_arn" {
  value = aws_iam_role.readonly.arn
}
