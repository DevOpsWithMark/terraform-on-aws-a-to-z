# chapters/ch11/main.tf
# Starts on local state. In Step 3 you copy extras/backend.tf
# into this folder and migrate the state to S3.

terraform {
  required_version = ">= 1.12"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      Chapter   = "11"
      ManagedBy = "terraform"
    }
  }
}

variable "bucket_name" {
  description = "Lab bucket name. S3 names are globally unique."
  type        = string
}

resource "aws_s3_bucket" "app" {
  bucket        = var.bucket_name
  force_destroy = true
}

# Publishes the bucket name where other configurations can
# read it without access to this state file.
resource "aws_ssm_parameter" "bucket_name" {
  name  = "/devopswm/ch11/bucket-name"
  type  = "String"
  value = aws_s3_bucket.app.bucket
}

# A deliberately slow step, so you can watch the lock file.
# terraform apply -var pause_seconds=90
variable "pause_seconds" {
  description = "Seconds the pause step sleeps (0 = no pause)"
  type        = number
  default     = 0
}

resource "terraform_data" "pause" {
  triggers_replace = var.pause_seconds

  provisioner "local-exec" {
    command = "sleep ${var.pause_seconds}"
  }
}
