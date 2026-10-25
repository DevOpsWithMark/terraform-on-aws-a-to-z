# chapters/ch11/reader/main.tf
# A second configuration that needs the bucket name from the
# first one. It shows two ways to get it. It creates nothing.

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

variable "state_bucket" {
  description = "State bucket name (from backend.hcl)"
  type        = string
}

# Way 1: read the other configuration's state file.
# Needs read access to the WHOLE state, secrets included.
data "terraform_remote_state" "lab" {
  backend = "s3"

  config = {
    bucket = var.state_bucket
    key    = "chapters/ch11/terraform.tfstate"
    region = "us-east-1"
  }
}

# Way 2: read one published value. Needs ssm:GetParameter
# on one parameter, nothing more.
data "aws_ssm_parameter" "bucket_name" {
  name = "/devopswm/ch11/bucket-name"
}

output "via_remote_state" {
  value = data.terraform_remote_state.lab.outputs.bucket_name
}

output "via_ssm" {
  value = data.aws_ssm_parameter.bucket_name.insecure_value
}
