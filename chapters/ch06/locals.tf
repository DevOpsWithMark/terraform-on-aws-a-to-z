# chapters/ch06/locals.tf

locals {
  name = "devopswm-ch06-${var.environment}"

  # Our tags first, then the caller's. On a key clash,
  # the later map wins, so var.tags can override these.
  common_tags = merge(
    {
      Environment = var.environment
      Lab         = "web"
    },
    var.tags,
  )
}
