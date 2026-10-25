# chapters/ch07/rules.tfvars
ingress_rules = [
  {
    description = "HTTP from anywhere"
    port        = 80
    cidr_blocks = ["0.0.0.0/0"]
  },
  {
    description = "HTTPS from anywhere"
    port        = 443
    cidr_blocks = ["0.0.0.0/0"]
  },
  {
    description = "App port from the VPC only"
    port        = 8080
    cidr_blocks = ["172.31.0.0/16"]
  },
]
