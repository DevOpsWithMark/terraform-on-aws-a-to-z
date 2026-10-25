# envs/prod/providers.tf
provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Chapter     = var.chapter
      Project     = "shortener"
      Environment = "prod"
      ManagedBy   = "terraform"
    }
  }
}
