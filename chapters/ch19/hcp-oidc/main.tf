# chapters/ch19/hcp-oidc/main.tf
# AWS side of HCP Terraform dynamic credentials: an OIDC
# identity provider for app.terraform.io and a role that only
# runs from your organization, project, and workspaces can
# assume. Apply this once from your laptop (local state).

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

locals {
  hcp_host = "app.terraform.io"
  audience = "aws.workload.identity"

  # One sub pattern per workspace, any run phase (plan/apply).
  subjects = [
    for ws in var.hcp_workspaces : join(":", [
      "organization", var.hcp_organization,
      "project", var.hcp_project,
      "workspace", ws,
      "run_phase", "*",
    ])
  ]
}

resource "aws_iam_openid_connect_provider" "hcp" {
  url            = "https://${local.hcp_host}"
  client_id_list = [local.audience]
}

data "aws_iam_policy_document" "trust" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.hcp.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.hcp_host}:aud"
      values   = [local.audience]
    }

    condition {
      test     = "StringLike"
      variable = "${local.hcp_host}:sub"
      values   = local.subjects
    }
  }
}

resource "aws_iam_role" "hcp_run" {
  name                 = "devopswm-ch19-hcp-run"
  assume_role_policy   = data.aws_iam_policy_document.trust.json
  max_session_duration = 3600
}

# The Chapter 19 practice roots only create a VPC, a subnet,
# a security group, and an S3 bucket. Scope this down further
# for real workloads.
resource "aws_iam_role_policy_attachment" "hcp_run" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonVPCFullAccess",
    "arn:aws:iam::aws:policy/AmazonS3FullAccess",
  ])

  role       = aws_iam_role.hcp_run.name
  policy_arn = each.value
}
