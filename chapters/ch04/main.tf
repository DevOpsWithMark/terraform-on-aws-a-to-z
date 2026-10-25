# chapters/ch04/main.tf
# S3 bucket names are globally unique: no two AWS accounts
# can share one. Replace <your bucket name> in all three
# buckets with your own name, e.g. devopswm-labs-ch04.

# 1. Default provider, default region (us-east-1).
resource "aws_s3_bucket" "east" {
  bucket = "<your bucket name>-east"
}

# 2. Same default provider, per-resource region (provider 6).
resource "aws_s3_bucket" "west_arg" {
  region = "us-west-2"
  bucket = "<your bucket name>-west-arg"
}

# 3. Aliased provider configuration (the classic way).
resource "aws_s3_bucket" "west_alias" {
  provider = aws.west
  bucket   = "<your bucket name>-west-alias"
}
