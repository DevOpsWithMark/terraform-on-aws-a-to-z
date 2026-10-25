# chapters/ch10/outputs.tf

output "bucket_name" {
  description = "Name of the lab bucket"
  value       = aws_s3_bucket.lab.bucket
}

output "bucket_arn" {
  description = "ARN of the lab bucket"
  value       = aws_s3_bucket.lab.arn
}
