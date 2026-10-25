# chapters/ch19/hcp-oidc/variables.tf

variable "hcp_organization" {
  description = "Your HCP Terraform organization name"
  type        = string
}

variable "hcp_project" {
  description = "HCP Terraform project that holds the workspaces"
  type        = string
  default     = "devopswithmark-labs"
}

variable "hcp_workspaces" {
  description = "Workspaces allowed to assume the run role"
  type        = list(string)
  default     = ["ch19-network", "ch19-app"]
}
