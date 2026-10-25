# modules/service/outputs.tf

output "alb_dns_name" {
  description = "DNS name of the load balancer (CloudFront's API origin)"
  value       = aws_lb.app.dns_name
}

output "ecr_repository_url" {
  description = "Push the app image here"
  value       = aws_ecr_repository.app.repository_url
}

output "cluster_name" {
  description = "ECS cluster name"
  value       = aws_ecs_cluster.this.name
}

output "service_name" {
  description = "ECS service name"
  value       = aws_ecs_service.app.name
}

output "table_name" {
  description = "DynamoDB table that stores the links"
  value       = aws_dynamodb_table.links.name
}

output "admin_token_secret_arn" {
  description = "Secrets Manager ARN of the admin token"
  value       = aws_secretsmanager_secret.admin_token.arn
}

output "log_group_name" {
  description = "CloudWatch log group for the app"
  value       = aws_cloudwatch_log_group.app.name
}
