# chapters/ch13/site/main.tf
# A practice root module that calls the real static-site
# child module. No API origin: just a page on CloudFront.

terraform {
  required_version = ">= 1.12"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      Chapter   = "13"
      ManagedBy = "terraform"
    }
  }
}

module "site" {
  source = "../../../modules/static-site"

  name      = "devopswm-ch13"
  files_dir = "${path.module}/hello"

  # e.g. devopswm-labs-ch13-site
  bucket_name = "<your bucket name>"
}

output "url" {
  description = "Open this in a browser"
  value       = module.site.url
}

output "bucket_name" {
  value = module.site.bucket_name
}
