# chapters/ch06/outputs.tf

output "environment" {
  description = "Which environment this is"
  value       = var.environment
}

output "instance_type" {
  description = "Instance type actually used"
  value       = aws_instance.web.instance_type
}

output "url" {
  description = "Open this in a browser"
  value       = "http://${aws_instance.web.public_ip}"
}

output "tags" {
  description = "Tags set on the instance by this config"
  value       = aws_instance.web.tags
}

# Built from a sensitive variable, so it must be sensitive.
output "status_url" {
  description = "Secret status page"
  value = join("", [
    "http://", aws_instance.web.public_ip,
    "/", var.status_token, ".html",
  ])
  sensitive = true
}
