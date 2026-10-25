# cicd/variables.tf

variable "github_sub_prefix" {
  description = "Start of the OIDC sub claim for your repository"
  type        = string

  # Print it with:
  #   gh api repos/OWNER/REPO/actions/oidc/customization/sub \
  #     --jq .sub_claim_prefix
  # Repositories created after July 15, 2026 include the owner
  # and repository IDs: repo:owner@123/name@456
  validation {
    condition = can(regex(
      "^repo:[A-Za-z0-9-]+(@[0-9]+)?/[A-Za-z0-9._-]+(@[0-9]+)?$",
      var.github_sub_prefix
    ))
    error_message = "Use the sub_claim_prefix that gh prints."
  }
}

variable "state_bucket" {
  description = "Name of the Terraform state bucket (Chapter 11)"
  type        = string
}
