# chapters/ch07/providers.tf
provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      Chapter   = "7"
      ManagedBy = "terraform"
    }
  }
}
