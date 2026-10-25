# chapters/ch07/address-shift/main.tf
# Free demo: terraform_data creates nothing in AWS.
terraform {
  required_version = ">= 1.12"
}

variable "users" {
  type    = list(string)
  default = ["alice", "bob", "carol"]
}

resource "terraform_data" "by_count" {
  count = length(var.users)
  input = var.users[count.index]
}

resource "terraform_data" "by_for_each" {
  for_each = toset(var.users)
  input    = each.value
}
