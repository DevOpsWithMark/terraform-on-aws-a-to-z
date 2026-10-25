# chapters/ch06/prod.tfvars
environment   = "prod"
instance_type = "t3.small"

web = {
  heading     = "Hello from prod"
  volume_size = 16
}

# Replaces the whole map from terraform.tfvars. No merging.
tags = {
  Owner = "platform-team"
  Tier  = "critical"
}
