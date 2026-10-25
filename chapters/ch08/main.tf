# chapters/ch08/main.tf

data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = [var.ami_name_pattern]
  }
}

data "aws_vpc" "default" {
  default = true
}

# ---------- Security group ----------
resource "aws_security_group" "web" {
  name_prefix = "devopswm-web-"
  description = "HTTP in, all out"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "HTTP from anywhere"
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

  lifecycle {
    create_before_destroy = true
  }
}

# ---------- IAM: lets Session Manager reach the server ----------
data "aws_iam_policy_document" "ec2_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "web" {
  name_prefix = "devopswm-web-"
  assume_role_policy = (
    data.aws_iam_policy_document.ec2_assume.json
  )
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role = aws_iam_role.web.name
  policy_arn = join("", [
    "arn:aws:iam::aws:policy/",
    "AmazonSSMManagedInstanceCore",
  ])
}

resource "aws_iam_instance_profile" "web" {
  name_prefix = "devopswm-web-"
  role        = aws_iam_role.web.name
}

# ---------- Replacement trigger ----------
resource "terraform_data" "release" {
  input = var.release
}

# ---------- Web server ----------
resource "aws_instance" "web" {
  ami                    = data.aws_ami.al2023.id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.web.id]
  iam_instance_profile   = aws_iam_instance_profile.web.name

  associate_public_ip_address = true
  user_data_replace_on_change = true
  user_data                   = <<-EOT
    #!/bin/bash
    dnf install -y httpd
    echo "<h1>${var.page_message}</h1>" > /var/www/html/index.html
    systemctl enable --now httpd
  EOT

  tags = {
    Name    = "devopswm-web"
    Release = var.release
  }

  # The instance never references the policy attachment,
  # so Terraform cannot see that it needs it.
  depends_on = [aws_iam_role_policy_attachment.ssm]

  lifecycle {
    create_before_destroy = true
    replace_triggered_by  = [terraform_data.release]

    precondition {
      condition     = data.aws_ami.al2023.architecture == "x86_64"
      error_message = "The AMI must be x86_64 to run on t3 types."
    }

    postcondition {
      condition     = self.public_ip != ""
      error_message = "The web server did not get a public IP."
    }
  }
}

# ---------- Continuous check: is the site up? ----------
check "site_up" {
  data "http" "home" {
    url = "http://${aws_instance.web.public_ip}"

    retry {
      attempts     = 6
      min_delay_ms = 5000
    }
  }

  assert {
    condition     = data.http.home.status_code == 200
    error_message = "The site did not return HTTP 200."
  }
}
