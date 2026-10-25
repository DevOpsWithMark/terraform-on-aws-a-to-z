# chapters/ch20/03-stuck-lock/main.tf
# Uses the S3 backend from Chapter 11 with a native lock file.
# Nothing here costs money: terraform_data lives only in state.
# The README shows how to leave a lock behind on purpose.

terraform {
  required_version = ">= 1.12"

  backend "s3" {
    key          = "lab/ch20/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}

resource "terraform_data" "marker" {
  input = "chapter 20 lock demo"
}

output "marker" {
  value = terraform_data.marker.output
}
