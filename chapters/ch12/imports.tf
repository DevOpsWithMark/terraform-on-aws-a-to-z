# chapters/ch12/imports.tf
# Each block says: "this real object (id) belongs at this
# address (to)". Delete this file after the import applies.

import {
  to = aws_s3_bucket.handmade
  id = var.bucket_name
}

import {
  to = aws_security_group.web
  id = var.sg_id
}
