# chapters/ch12/variables.tf
# Values come from terraform.tfvars, written in Step 1.

variable "bucket_name" {
  description = "Name of the bucket you created by hand"
  type        = string
}

variable "sg_id" {
  description = "ID of the security group you created by hand"
  type        = string
}
