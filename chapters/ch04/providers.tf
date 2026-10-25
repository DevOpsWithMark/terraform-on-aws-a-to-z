# chapters/ch04/providers.tf

# Default configuration: no alias, us-east-1.
provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      Chapter   = "4"
      ManagedBy = "terraform"
    }
  }
}

# A second, aliased configuration for us-west-2.
# default_tags belong to one configuration, so repeat them.
provider "aws" {
  alias  = "west"
  region = "us-west-2"

  default_tags {
    tags = {
      Chapter   = "4"
      ManagedBy = "terraform"
    }
  }
}
