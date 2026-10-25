# chapters/ch06/main.tf

resource "aws_security_group" "web" {
  name        = "${local.name}-web"
  description = "Lab web server: HTTP"
  vpc_id      = data.aws_vpc.default.id
  tags        = local.common_tags
}

# LAB ONLY when allowed_cidr is 0.0.0.0/0 (the default).
resource "aws_vpc_security_group_ingress_rule" "http" {
  security_group_id = aws_security_group.web.id
  description       = "HTTP"
  cidr_ipv4         = var.web.allowed_cidr
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
}

resource "aws_vpc_security_group_egress_rule" "all" {
  security_group_id = aws_security_group.web.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_instance" "web" {
  ami                    = data.aws_ami.al2023.id
  instance_type          = var.instance_type
  subnet_id              = sort(data.aws_subnets.default.ids)[0]
  vpc_security_group_ids = [aws_security_group.web.id]

  metadata_options {
    http_tokens = "required"
  }

  root_block_device {
    volume_size = var.web.volume_size
  }

  user_data = <<-EOT
    #!/bin/bash
    MD=http://169.254.169.254/latest
    TOKEN=$(curl -sX PUT $MD/api/token \
      -H "X-aws-ec2-metadata-token-ttl-seconds: 300")
    ID=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" \
      $MD/meta-data/instance-id)
    dnf install -y nginx
    WWW=/usr/share/nginx/html
    echo "<h1>${var.web.heading} from $ID</h1>" \
      > $WWW/index.html
    echo "<p>env: ${var.environment}</p>" >> $WWW/index.html
    echo "ok" > "$WWW/${var.status_token}.html"
    systemctl enable --now nginx
  EOT

  user_data_replace_on_change = true

  tags = merge(local.common_tags, { Name = local.name })
}
