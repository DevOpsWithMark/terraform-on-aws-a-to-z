# chapters/ch07/terraform.tfvars
bucket_name = "<your bucket name>" # e.g. devopswm-labs-ch07

buckets = {
  assets = {
    purpose    = "Images and CSS"
    versioning = true
  }
  reports = {
    purpose    = "Nightly CSV exports"
    versioning = false
  }
  backups = {
    purpose    = "Database dumps"
    versioning = true
  }
}
