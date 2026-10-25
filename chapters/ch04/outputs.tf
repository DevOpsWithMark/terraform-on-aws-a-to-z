# chapters/ch04/outputs.tf

output "east_bucket" {
  value = aws_s3_bucket.east.bucket
}

output "west_arg_bucket_region" {
  value = aws_s3_bucket.west_arg.bucket_region
}

output "west_alias_bucket_region" {
  value = aws_s3_bucket.west_alias.bucket_region
}
