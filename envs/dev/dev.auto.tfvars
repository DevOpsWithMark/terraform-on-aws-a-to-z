# envs/dev/dev.auto.tfvars
# Loaded automatically because the name ends in .auto.tfvars.
# Chapter 15 sets desired_count = 0 for the first apply (the
# image is not in ECR yet), then back to 2 after the push.
desired_count = 2
image_tag     = "1.0.0"
# e.g. devopswm-shortener-dev-site
site_bucket_name = "<your bucket name>"
