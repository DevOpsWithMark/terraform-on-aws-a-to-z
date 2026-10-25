# chapters/ch09/main.tf

locals {
  # Secret names only need to be unique in your account.
  prefix = "devopswm-ch09"
}

# ---------- 1. Old way: the value lands in state ----------
resource "random_password" "old" {
  length  = 24
  special = false
}

resource "aws_secretsmanager_secret" "old" {
  name                    = "${local.prefix}/old-way"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "old" {
  secret_id     = aws_secretsmanager_secret.old.id
  secret_string = random_password.old.result
}

# ---------- 2. Ephemeral + write-only: not in state ----------
ephemeral "random_password" "token" {
  length  = 24
  special = false
}

resource "aws_secretsmanager_secret" "token" {
  name                    = "${local.prefix}/token"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "token" {
  secret_id = aws_secretsmanager_secret.token.id

  # Sent to AWS during apply; never saved in state or plan.
  secret_string_wo = (
    ephemeral.random_password.token.result
  )
  secret_string_wo_version = var.token_version
}

# ---------- 3. Ephemeral variable + write-only ----------
resource "aws_secretsmanager_secret" "api_key" {
  name                    = "${local.prefix}/api-key"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "api_key" {
  secret_id                = aws_secretsmanager_secret.api_key.id
  secret_string_wo         = var.api_key
  secret_string_wo_version = var.api_key_version
}
