# modules/static-site/tests/integration/site_apply.tftest.hcl
# Integration test (Chapter 17): creates a REAL bucket and
# CloudFront distribution, checks the page, then destroys
# everything. Takes 5-15 minutes and costs a few cents.
# Not run by a plain `terraform test` (subfolders of tests/
# are not scanned). Run from modules/static-site:
#   terraform init -test-directory=tests/integration
#   terraform test -test-directory=tests/integration

provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      Chapter   = "17"
      ManagedBy = "terraform"
    }
  }
}

variables {
  name = "devopswm-tftest"
  # S3 bucket names are globally unique: use your own.
  # e.g. devopswm-labs-ch17-tftest
  bucket_name = "<your bucket name>"
  files_dir   = "../../app/public"
}

run "deploy_site" {
  command = apply

  assert {
    condition     = endswith(output.url, ".cloudfront.net")
    error_message = "url must be a CloudFront default domain."
  }

  assert {
    condition     = length(aws_s3_object.files) == 3
    error_message = "All three site files must be uploaded."
  }
}

run "page_is_served" {
  command = apply

  # A tiny helper module that only reads the URL over HTTPS.
  module {
    source = "./tests/integration/http-get"
  }

  variables {
    url = run.deploy_site.url
  }

  assert {
    condition     = data.http.page.status_code == 200
    error_message = "The site did not return HTTP 200."
  }

  assert {
    condition = strcontains(
      data.http.page.response_body, "URL Shortener"
    )
    error_message = "The page does not look like the app."
  }
}
