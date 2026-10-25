# modules/static-site/outputs.tf

output "bucket_name" {
  description = "Name of the S3 bucket that holds the site files"
  value       = aws_s3_bucket.site.bucket
}

output "distribution_id" {
  description = "CloudFront distribution ID"
  value       = aws_cloudfront_distribution.site.id
}

output "distribution_arn" {
  description = "CloudFront distribution ARN"
  value       = aws_cloudfront_distribution.site.arn
}

output "url" {
  description = "Public HTTPS URL of the site"
  value = format(
    "https://%s", aws_cloudfront_distribution.site.domain_name
  )
}
