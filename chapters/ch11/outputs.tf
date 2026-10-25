# chapters/ch11/outputs.tf

output "bucket_name" {
  description = "Name of the lab bucket"
  value       = aws_s3_bucket.app.bucket
}

output "parameter_name" {
  description = "SSM parameter that holds the bucket name"
  value       = aws_ssm_parameter.bucket_name.name
}
