# chapters/ch06/data.tf
# Data sources read things that already exist. Terraform
# never creates, changes, or deletes them.

# Latest Amazon Linux 2023 image, published by Amazon.
data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023*-x86_64"]
  }
}

# The default VPC that every account has in every Region.
data "aws_vpc" "default" {
  default = true
}

# Availability Zones that offer the chosen type.
data "aws_ec2_instance_type_offerings" "zones" {
  location_type = "availability-zone"

  filter {
    name   = "instance-type"
    values = [var.instance_type]
  }
}

# Default subnets in that VPC, in a zone that has that type.
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }

  filter {
    name   = "default-for-az"
    values = ["true"]
  }

  filter {
    name   = "availability-zone"
    values = data.aws_ec2_instance_type_offerings.zones.locations
  }
}
