# modules/service/tests/service.tftest.hcl
# Unit tests (Chapter 17). AWS is mocked; every run is a plan.
# The random provider is NOT mocked: the module uses an
# ephemeral random_password, and mock providers before
# Terraform 1.17 do not support ephemeral resources. The real
# random provider runs locally and never calls a cloud API.
# Run from modules/service:
#   terraform init && terraform test

mock_provider "aws" {
  mock_data "aws_iam_policy_document" {
    defaults = {
      json = <<-EOT
        {"Version": "2012-10-17", "Statement": []}
      EOT
    }
  }
}

# Data sources get fixed, realistic values.
override_data {
  target = data.aws_region.current
  values = {
    region = "us-east-1"
  }
}

override_data {
  target = data.aws_ec2_managed_prefix_list.cloudfront
  values = {
    id = "pl-3b927c52"
  }
}

variables {
  name               = "devopswm-shortener-test"
  vpc_id             = "vpc-0123456789abcdef0"
  public_subnet_ids  = ["subnet-0aaa1111", "subnet-0bbb2222"]
  private_subnet_ids = ["subnet-0ccc3333", "subnet-0ddd4444"]
}

run "defaults_are_safe" {
  command = plan

  assert {
    condition     = aws_ecs_service.app.desired_count == 2
    error_message = "Default desired_count should be 2."
  }

  assert {
    condition = (
      aws_ecs_service.app.network_configuration[0]
      .assign_public_ip == false
    )
    error_message = "Tasks must not get public IP addresses."
  }

  assert {
    condition = (
      aws_vpc_security_group_ingress_rule.alb_http.prefix_list_id
      == "pl-3b927c52"
    )
    error_message = "ALB ingress must come from CloudFront only."
  }

  assert {
    condition = (
      aws_dynamodb_table.links.point_in_time_recovery[0].enabled
      == false
    )
    error_message = "PITR is off unless the caller turns it on."
  }
}

run "desired_count_is_passed_through" {
  command = plan

  variables {
    desired_count = 0
  }

  assert {
    condition     = aws_ecs_service.app.desired_count == 0
    error_message = "desired_count must reach the ECS service."
  }
}

run "prod_settings_are_passed_through" {
  command = plan

  variables {
    point_in_time_recovery = true
    log_retention_days     = 30
  }

  assert {
    condition = (
      aws_dynamodb_table.links.point_in_time_recovery[0].enabled
    )
    error_message = "PITR must be on when requested."
  }

  assert {
    condition = (
      aws_cloudwatch_log_group.app.retention_in_days == 30
    )
    error_message = "Log retention must follow the input."
  }
}

run "rejects_uppercase_name" {
  command = plan

  variables {
    name = "Shortener-Dev"
  }

  expect_failures = [var.name]
}

run "rejects_name_longer_than_26" {
  command = plan

  variables {
    # 27 characters, one over the limit.
    name = "devopswm-shortener-staging1"
  }

  expect_failures = [var.name]
}
