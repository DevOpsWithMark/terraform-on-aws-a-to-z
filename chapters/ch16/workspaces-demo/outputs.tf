# chapters/ch16/workspaces-demo/outputs.tf

output "workspace" {
  description = "The CLI workspace this state belongs to"
  value       = terraform.workspace
}

output "bucket_name" {
  description = "Name of this workspace's demo bucket"
  value       = aws_s3_bucket.demo.bucket
}

output "expire_days" {
  description = "Object expiry chosen for this workspace"
  value       = local.cfg.expire_days
}
