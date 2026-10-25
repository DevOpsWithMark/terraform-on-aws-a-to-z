# chapters/ch11/extras/backend.tf
# Copy this file into chapters/ch11/ in Step 3. The bucket
# name is not here: it comes from backend.hcl at init time.
#   terraform init -backend-config=../../backend.hcl

terraform {
  backend "s3" {
    key          = "chapters/ch11/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}
