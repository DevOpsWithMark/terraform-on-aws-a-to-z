# modules/static-site/tests/integration/http-get/main.tf
# Test helper: fetches one URL. Used only by the integration
# test; it creates no resources.

terraform {
  required_version = ">= 1.12"

  required_providers {
    http = {
      source  = "hashicorp/http"
      version = "~> 3.6"
    }
  }
}

variable "url" {
  description = "URL to fetch"
  type        = string
}

data "http" "page" {
  url = var.url

  # Retries connection errors and 5xx answers while a new
  # distribution settles.
  retry {
    attempts     = 6
    min_delay_ms = 10000
  }
}

output "status_code" {
  description = "HTTP status code of the response"
  value       = data.http.page.status_code
}
