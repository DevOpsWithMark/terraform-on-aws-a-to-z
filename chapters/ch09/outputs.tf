# chapters/ch09/outputs.tf
output "secret_names" {
  description = "Secrets Manager names created by this lab"
  value = [
    aws_secretsmanager_secret.old.name,
    aws_secretsmanager_secret.token.name,
    aws_secretsmanager_secret.api_key.name,
  ]
}

# Redacted in the CLI, but still stored in state.
output "old_password" {
  description = "The old-way password (for the demo only)"
  value       = random_password.old.result
  sensitive   = true
}
