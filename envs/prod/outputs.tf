# envs/prod/outputs.tf

output "app_url" {
  description = "Open this in a browser"
  value       = module.site.url
}

output "ecr_repository_url" {
  description = "Where scripts/push-image.sh pushes the image"
  value       = module.service.ecr_repository_url
}

output "cluster_name" {
  description = "ECS cluster name"
  value       = module.service.cluster_name
}

output "service_name" {
  description = "ECS service name"
  value       = module.service.service_name
}

output "table_name" {
  description = "DynamoDB table that stores the links"
  value       = module.service.table_name
}

output "admin_token_secret_arn" {
  description = "Secrets Manager ARN of the admin token"
  value       = module.service.admin_token_secret_arn
}
