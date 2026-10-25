# chapters/ch05/main.tf

resource "aws_security_group" "web" {
  name        = "devopswm-ch05-web"
  description = "Lab web server: HTTP from anywhere"
  vpc_id      = data.aws_vpc.default.id
}

# LAB ONLY: port 80 open to the whole internet.
resource "aws_vpc_security_group_ingress_rule" "http" {
  security_group_id = aws_security_group.web.id
  description       = "HTTP from anywhere (lab only)"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
}

# Outbound: lets the instance download nginx.
resource "aws_vpc_security_group_egress_rule" "all" {
  security_group_id = aws_security_group.web.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_instance" "web" {
  ami                    = data.aws_ami.al2023.id
  instance_type          = "t3.micro"
  subnet_id              = sort(data.aws_subnets.default.ids)[0]
  vpc_security_group_ids = [aws_security_group.web.id]

  # Require IMDSv2 tokens for the instance metadata service.
  metadata_options {
    http_tokens = "required"
  }

  # Runs once, as root, on first boot.
  user_data = <<-EOT
    #!/bin/bash
    MD=http://169.254.169.254/latest
    TOKEN=$(curl -sX PUT $MD/api/token \
      -H "X-aws-ec2-metadata-token-ttl-seconds: 300")
    ID=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" \
      $MD/meta-data/instance-id)
    dnf install -y nginx
    echo "<h1>Hello from $ID</h1>" \
      > /usr/share/nginx/html/index.html
    systemctl enable --now nginx
  EOT

  # Edit the script above and Terraform replaces the server.
  user_data_replace_on_change = true

  tags = {
    Name = "devopswm-ch05-web"
  }
}
