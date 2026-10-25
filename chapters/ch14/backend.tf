# chapters/ch14/backend.tf
# Same state bucket as the app, but its own key. The bucket
# name comes from backend.hcl:
#   terraform init -backend-config=../../backend.hcl
terraform {
  backend "s3" {
    key          = "shortener/ch14/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}
