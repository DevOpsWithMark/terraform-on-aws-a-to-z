# chapters/ch19/hcp-oidc/outputs.tf

output "run_role_arn" {
  description = "Value for TFC_AWS_RUN_ROLE_ARN"
  value       = aws_iam_role.hcp_run.arn
}

output "trusted_subjects" {
  description = "sub claims the role trusts"
  value       = local.subjects
}
