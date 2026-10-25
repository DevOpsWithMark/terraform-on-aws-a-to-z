# cicd/backend.tf
# Same state bucket as the environments, its own key:
#   terraform init -backend-config=../backend.hcl
terraform {
  backend "s3" {
    key          = "shortener/cicd/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}
