# chapters/ch12/steps/06-moved.tf
# Tells Terraform the objects moved; nothing is replaced.
# Copy to ../moved.tf.

moved {
  from = aws_s3_bucket.handmade
  to   = module.logs.aws_s3_bucket.this
}

moved {
  from = aws_security_group.web
  to   = aws_security_group.public_http
}
