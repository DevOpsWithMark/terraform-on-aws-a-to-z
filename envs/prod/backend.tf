# envs/prod/backend.tf
# The bucket name comes from backend.hcl (partial configuration):
#   terraform init -backend-config=../../backend.hcl
terraform {
  backend "s3" {
    key          = "shortener/prod/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}
