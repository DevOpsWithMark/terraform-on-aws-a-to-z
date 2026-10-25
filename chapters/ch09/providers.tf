# chapters/ch09/providers.tf
provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      Chapter   = "9"
      ManagedBy = "terraform"
    }
  }
}
