# chapters/ch07/outputs.tf
output "bucket_names" {
  description = "Short name => real bucket name"
  value       = { for k, b in aws_s3_bucket.this : k => b.bucket }
}

output "versioned_buckets" {
  description = "Short names of buckets with versioning on"
  value       = sort(keys(local.versioned))
}

output "log_bucket" {
  description = "Log bucket name, or null when logs are off"
  value       = one(aws_s3_bucket.logs[*].bucket)
}

output "ingress_ports" {
  description = "Ports opened on the web security group"
  value       = var.ingress_rules[*].port
}
