# cicd/main.tf
# Lets GitHub Actions in ONE repository assume AWS roles with
# short-lived OIDC tokens instead of stored access keys
# (Chapter 18). Apply this root from your machine, once.

locals {
  oidc_host = "token.actions.githubusercontent.com"
  repo      = var.github_sub_prefix
}

# ---------- Trust GitHub's token issuer ----------
# One per account per URL. No thumbprint_list: AWS verifies
# GitHub's certificate with its own trusted CAs.
resource "aws_iam_openid_connect_provider" "github" {
  url            = "https://${local.oidc_host}"
  client_id_list = ["sts.amazonaws.com"]
}

# ---------- Plan role ----------
# Pull requests and pushes to main may plan.
data "aws_iam_policy_document" "plan_trust" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_host}:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_host}:sub"
      values = [
        "${local.repo}:pull_request",
        "${local.repo}:ref:refs/heads/main",
      ]
    }
  }
}

resource "aws_iam_role" "plan" {
  name                 = "devopswm-shortener-gha-plan"
  description          = "GitHub Actions: terraform plan"
  max_session_duration = 3600

  assume_role_policy = (
    data.aws_iam_policy_document.plan_trust.json
  )
}

resource "aws_iam_role_policy_attachment" "plan_read" {
  role       = aws_iam_role.plan.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

# What plan needs beyond read-only.
data "aws_iam_policy_document" "plan_extra" {
  # Plan takes the state lock: it writes <key>.tflock, then
  # deletes it. It never writes the state file itself.
  statement {
    sid     = "StateLockFiles"
    actions = ["s3:PutObject", "s3:DeleteObject"]
    resources = [
      "arn:aws:s3:::${var.state_bucket}/shortener/*.tflock",
    ]
  }

  # No secret reads: the admin token is write-only, so refreshing
  # its secret version only lists version IDs (provider 6.26+),
  # which ReadOnlyAccess already allows.
}

resource "aws_iam_role_policy" "plan_extra" {
  name   = "state-lock-files"
  role   = aws_iam_role.plan.id
  policy = data.aws_iam_policy_document.plan_extra.json
}

# ---------- Apply role ----------
# Only jobs that run in the dev or prod GitHub environment.
data "aws_iam_policy_document" "apply_trust" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_host}:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_host}:sub"
      values = [
        "${local.repo}:environment:dev",
        "${local.repo}:environment:prod",
      ]
    }
  }
}

resource "aws_iam_role" "apply" {
  name                 = "devopswm-shortener-gha-apply"
  description          = "GitHub Actions: terraform apply"
  max_session_duration = 3600

  assume_role_policy = (
    data.aws_iam_policy_document.apply_trust.json
  )
}

# LAB ONLY. Production: a policy scoped to the services this
# stack uses, plus a permissions boundary (Chapter 21).
resource "aws_iam_role_policy_attachment" "apply_admin" {
  role       = aws_iam_role.apply.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}
