# chapters/ch07/main.tf

locals {
  # Only the buckets that asked for versioning.
  versioned = {
    for k, b in var.buckets : k => b if b.versioning
  }
}

# ---------- Buckets from a map ----------
resource "aws_s3_bucket" "this" {
  for_each = var.buckets

  bucket        = "${var.bucket_name}-${each.key}"
  force_destroy = true

  tags = {
    Name    = each.key
    Purpose = each.value.purpose
  }
}

resource "aws_s3_bucket_versioning" "this" {
  for_each = local.versioned

  bucket = aws_s3_bucket.this[each.key].id

  versioning_configuration {
    status = "Enabled"
  }
}

# A README in every bucket, rendered from a template.
resource "aws_s3_object" "readme" {
  for_each = aws_s3_bucket.this

  bucket       = each.value.id
  key          = "README.txt"
  content_type = "text/plain"
  content = templatefile("${path.module}/readme.tftpl", {
    bucket     = each.value.bucket
    purpose    = var.buckets[each.key].purpose
    versioning = var.buckets[each.key].versioning
  })
}

# ---------- Conditional log bucket ----------
resource "aws_s3_bucket" "logs" {
  count = var.enable_logs ? 1 : 0

  bucket        = "${var.bucket_name}-logs"
  force_destroy = true
}

# Let the S3 logging service write into the log bucket.
resource "aws_s3_bucket_policy" "logs" {
  count = var.enable_logs ? 1 : 0

  bucket = aws_s3_bucket.logs[0].id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid       = "S3ServerAccessLogs"
      Effect    = "Allow"
      Principal = { Service = "logging.s3.amazonaws.com" }
      Action    = "s3:PutObject"
      Resource  = "${aws_s3_bucket.logs[0].arn}/*"
    }]
  })
}

resource "aws_s3_bucket_logging" "this" {
  for_each = {
    for k, b in aws_s3_bucket.this : k => b.id if var.enable_logs
  }

  bucket        = each.value
  target_bucket = aws_s3_bucket.logs[0].id
  target_prefix = "${each.key}/"
}

# ---------- Security group with dynamic ingress ----------
data "aws_vpc" "default" {
  default = true
}

resource "aws_security_group" "web" {
  name        = "devopswm-ch07-web"
  description = "Web server rules built from a variable"
  vpc_id      = data.aws_vpc.default.id

  dynamic "ingress" {
    for_each = var.ingress_rules
    iterator = rule

    content {
      description = rule.value.description
      from_port   = rule.value.port
      to_port     = rule.value.port
      protocol    = "tcp"
      cidr_blocks = rule.value.cidr_blocks
    }
  }

  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
