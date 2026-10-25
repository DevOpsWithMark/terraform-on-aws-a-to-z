# .tflint.hcl
# TFLint settings for the whole repository (Chapter 17).
# Install the plugins once with: tflint --init

plugin "terraform" {
  enabled = true
  preset  = "recommended"
}

plugin "aws" {
  enabled = true
  version = "0.49.0"
  source  = "github.com/terraform-linters/tflint-ruleset-aws"
}
