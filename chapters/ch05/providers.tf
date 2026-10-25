# chapters/ch05/providers.tf
provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      Chapter   = "5"
      ManagedBy = "terraform"
    }
  }
}
