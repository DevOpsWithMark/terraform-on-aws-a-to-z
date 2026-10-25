# cicd/outputs.tf
# Copy these into the GitHub repository variables
# PLAN_ROLE_ARN and APPLY_ROLE_ARN.

output "plan_role_arn" {
  description = "Role for plan jobs (pull requests and main)"
  value       = aws_iam_role.plan.arn
}

output "apply_role_arn" {
  description = "Role for apply jobs (dev and prod environments)"
  value       = aws_iam_role.apply.arn
}

output "oidc_provider_arn" {
  description = "ARN of the GitHub OIDC identity provider"
  value       = aws_iam_openid_connect_provider.github.arn
}
