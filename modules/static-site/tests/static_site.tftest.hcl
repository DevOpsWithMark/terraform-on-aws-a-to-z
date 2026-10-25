# modules/static-site/tests/static_site.tftest.hcl
# Unit tests (Chapter 17). No AWS calls: the AWS provider is
# mocked and every run uses command = plan.
# Run from modules/static-site:
#   terraform init && terraform test

mock_provider "aws" {
  # Mocked strings are random by default. Policy arguments
  # are validated as JSON, so give the document a real one.
  mock_data "aws_iam_policy_document" {
    defaults = {
      json = <<-EOT
        {"Version": "2012-10-17", "Statement": []}
      EOT
    }
  }
}

# The bucket's regional domain is computed by AWS. A fixed value,
# known at plan time, makes it predictable enough to assert on.
override_resource {
  target          = aws_s3_bucket.site
  override_during = plan
  values = {
    bucket_regional_domain_name = (
      "devopswm-test-site.s3.us-east-1.amazonaws.com"
    )
  }
}

variables {
  name        = "devopswm-test"
  bucket_name = "devopswm-test-site"
  files_dir   = "../../app/public"
}

run "site_only_has_no_api_behaviors" {
  command = plan

  assert {
    condition = length(
      aws_cloudfront_distribution.site.ordered_cache_behavior
    ) == 0
    error_message = "No API origin given, so no API behaviors."
  }
}

run "api_origin_adds_two_ordered_behaviors" {
  command = plan

  variables {
    api_origin_domain = "my-alb-123.us-east-1.elb.amazonaws.com"
  }

  assert {
    condition = length(
      aws_cloudfront_distribution.site.ordered_cache_behavior
    ) == 2
    error_message = "Expected behaviors for /api/* and /r/*."
  }

  assert {
    condition = (
      aws_cloudfront_distribution.site.ordered_cache_behavior[*]
      .path_pattern == tolist(["/api/*", "/r/*"])
    )
    error_message = "API paths must be /api/* then /r/*."
  }

  assert {
    condition = alltrue([
      for b in aws_cloudfront_distribution.site
      .ordered_cache_behavior : b.target_origin_id == "api"
    ])
    error_message = "API behaviors must target the api origin."
  }
}

run "bucket_is_the_s3_origin" {
  command = plan

  assert {
    condition     = aws_s3_bucket.site.bucket == "devopswm-test-site"
    error_message = "The bucket must use the bucket_name input."
  }

  assert {
    condition = contains(
      aws_cloudfront_distribution.site.origin[*].domain_name,
      "devopswm-test-site.s3.us-east-1.amazonaws.com"
    )
    error_message = "CloudFront must use the bucket as an origin."
  }
}

run "uploads_every_file" {
  command = plan

  assert {
    condition     = length(aws_s3_object.files) == 3
    error_message = "Expected index.html, app.js, and style.css."
  }

  assert {
    condition = (
      aws_s3_object.files["index.html"].content_type
      == "text/html; charset=utf-8"
    )
    error_message = "HTML must be served as text/html."
  }
}

run "rejects_uppercase_name" {
  command = plan

  variables {
    name = "DevOpsWM-Test"
  }

  expect_failures = [var.name]
}

run "rejects_invalid_bucket_name" {
  command = plan

  variables {
    bucket_name = "<your bucket name>"
  }

  expect_failures = [var.bucket_name]
}
