# chapters/ch12/steps/09-removed.tf
# Stop managing the bucket, but leave it in AWS.
# Copy to ../removed.tf after deleting the module "logs"
# block from main.tf.

removed {
  from = module.logs

  lifecycle {
    destroy = false
  }
}
