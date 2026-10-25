# modules/static-site/main.tf
# A private S3 bucket served through CloudFront. Optionally,
# CloudFront also forwards /api/* and /r/* to an API origin
# (the load balancer), so pages and API share one URL.

resource "aws_s3_bucket" "site" {
  bucket        = var.bucket_name
  force_destroy = var.force_destroy
}

resource "aws_s3_bucket_public_access_block" "site" {
  bucket                  = aws_s3_bucket.site.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

locals {
  content_types = {
    html = "text/html; charset=utf-8"
    css  = "text/css"
    js   = "application/javascript"
    json = "application/json"
    png  = "image/png"
    svg  = "image/svg+xml"
    ico  = "image/x-icon"
  }
}

resource "aws_s3_object" "files" {
  for_each = fileset(var.files_dir, "**")

  bucket = aws_s3_bucket.site.id
  key    = each.value
  source = "${var.files_dir}/${each.value}"
  etag   = filemd5("${var.files_dir}/${each.value}")
  content_type = lookup(
    local.content_types,
    reverse(split(".", each.value))[0],
    "application/octet-stream"
  )
}

# AWS-managed CloudFront policies, looked up by name.
data "aws_cloudfront_cache_policy" "optimized" {
  name = "Managed-CachingOptimized"
}

data "aws_cloudfront_cache_policy" "disabled" {
  name = "Managed-CachingDisabled"
}

data "aws_cloudfront_origin_request_policy" "all_viewer" {
  name = "Managed-AllViewerExceptHostHeader"
}

resource "aws_cloudfront_origin_access_control" "site" {
  name                              = "${var.name}-site"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

locals {
  s3_origin_id  = "s3-site"
  api_origin_id = "api"
  s3_domain     = aws_s3_bucket.site.bucket_regional_domain_name
  oac_id        = aws_cloudfront_origin_access_control.site.id

  # Managed policy IDs, shortened for readability below.
  cache_on   = data.aws_cloudfront_cache_policy.optimized.id
  cache_off  = data.aws_cloudfront_cache_policy.disabled.id
  all_viewer = data.aws_cloudfront_origin_request_policy.all_viewer.id
  # Only add API behaviors when an API origin is given.
  api_paths = var.api_origin_domain == null ? [] : var.api_paths
}

resource "aws_cloudfront_distribution" "site" {
  enabled             = true
  comment             = "${var.name} site"
  default_root_object = "index.html"
  price_class         = var.price_class

  origin {
    origin_id                = local.s3_origin_id
    domain_name              = local.s3_domain
    origin_access_control_id = local.oac_id
  }

  dynamic "origin" {
    for_each = var.api_origin_domain == null ? [] : [1]
    content {
      origin_id   = local.api_origin_id
      domain_name = var.api_origin_domain

      custom_origin_config {
        http_port              = 80
        https_port             = 443
        origin_protocol_policy = "http-only"
        origin_ssl_protocols   = ["TLSv1.2"]
      }
    }
  }

  default_cache_behavior {
    target_origin_id       = local.s3_origin_id
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    cache_policy_id        = local.cache_on
    compress               = true
  }

  dynamic "ordered_cache_behavior" {
    for_each = local.api_paths
    content {
      path_pattern           = ordered_cache_behavior.value
      target_origin_id       = local.api_origin_id
      viewer_protocol_policy = "redirect-to-https"
      allowed_methods = [
        "GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"
      ]
      cached_methods           = ["GET", "HEAD"]
      cache_policy_id          = local.cache_off
      origin_request_policy_id = local.all_viewer
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

# Only this distribution may read the bucket.
data "aws_iam_policy_document" "site" {
  statement {
    sid       = "AllowCloudFrontRead"
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.site.arn}/*"]

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.site.arn]
    }
  }
}

resource "aws_s3_bucket_policy" "site" {
  bucket = aws_s3_bucket.site.id
  policy = data.aws_iam_policy_document.site.json

  depends_on = [aws_s3_bucket_public_access_block.site]
}
