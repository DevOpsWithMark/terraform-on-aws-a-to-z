# envs/prod/main.tf
# The URL Shortener, prod environment.

locals {
  name = "devopswm-shortener-prod"
}

module "network" {
  source = "../../modules/network"

  name       = local.name
  cidr_block = "10.1.0.0/16"
  az_count   = 2
}

module "service" {
  source = "../../modules/service"

  name               = local.name
  vpc_id             = module.network.vpc_id
  public_subnet_ids  = module.network.public_subnet_ids
  private_subnet_ids = module.network.private_subnet_ids

  image_tag              = var.image_tag
  desired_count          = var.desired_count
  log_retention_days     = 30
  point_in_time_recovery = true
}

module "site" {
  source = "../../modules/static-site"

  name              = local.name
  bucket_name       = var.site_bucket_name
  files_dir         = "${path.root}/../../app/public"
  api_origin_domain = module.service.alb_dns_name
}
