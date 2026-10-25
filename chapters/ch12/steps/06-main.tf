# chapters/ch12/steps/06-main.tf
# After the refactor: the bucket lives in a module and the
# security group has a clearer name. Copy to ../main.tf.

data "aws_vpc" "default" {
  default = true
}

module "logs" {
  source = "./modules/bucket"

  name = var.bucket_name
}

resource "aws_security_group" "public_http" {
  name        = "devopswm-handmade-web"
  description = "Made by hand for Chapter 12"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "devopswm-handmade-web"
  }
}
