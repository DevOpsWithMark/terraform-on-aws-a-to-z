# cicd/providers.tf
provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      Chapter   = "18"
      Project   = "shortener"
      ManagedBy = "terraform"
    }
  }
}
