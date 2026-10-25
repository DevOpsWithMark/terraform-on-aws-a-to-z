# chapters/ch19/network/cloud.tf
# Connects this root to HCP Terraform. The organization comes
# from the TF_CLOUD_ORGANIZATION environment variable, so the
# file works for every reader unchanged.
terraform {
  cloud {
    workspaces {
      project = "devopswithmark-labs"
      name    = "ch19-network"
    }
  }
}
