# chapters/ch06/providers.tf
provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      Chapter   = "6"
      ManagedBy = "terraform"
    }
  }
}
