# chapters/ch08/providers.tf
provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      Chapter   = "8"
      ManagedBy = "terraform"
    }
  }
}
