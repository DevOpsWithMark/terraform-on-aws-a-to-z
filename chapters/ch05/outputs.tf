# chapters/ch05/outputs.tf

output "ami_id" {
  value = data.aws_ami.al2023.id
}

output "instance_id" {
  value = aws_instance.web.id
}

output "public_ip" {
  value = aws_instance.web.public_ip
}

output "url" {
  value = "http://${aws_instance.web.public_ip}"
}
