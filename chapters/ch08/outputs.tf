# chapters/ch08/outputs.tf
output "url" {
  description = "Test page URL"
  value       = "http://${aws_instance.web.public_ip}"

  precondition {
    condition     = aws_instance.web.public_ip != ""
    error_message = "No public IP, so there is no URL."
  }
}

output "instance_id" {
  description = "Current web server instance"
  value       = aws_instance.web.id
}

output "ami_id" {
  description = "AMI the server runs"
  value       = data.aws_ami.al2023.id
}
