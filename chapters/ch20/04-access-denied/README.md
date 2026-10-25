# 04-access-denied

**Setup (as your admin profile):**

```bash
cd setup
terraform init && terraform apply
cd ..
export TF_VAR_role_arn="$(terraform -chdir=setup output -raw role_arn)"
```

**Break:** `terraform init && terraform apply`

```text
Error: creating Security Group (devopswm-ch20-denied): operation
error EC2: CreateSecurityGroup, https response error
StatusCode: 403, RequestID: 5f0c...e2, api error
UnauthorizedOperation: You are not authorized to perform this
operation. User: arn:aws:sts::111122223333:assumed-role/
devopswm-ch20-readonly/devopswm-ch20 is not authorized to perform:
ec2:CreateSecurityGroup on resource: arn:aws:ec2:us-east-1:
111122223333:vpc/vpc-0566c28aaa8e02193 because no identity-based
policy allows the ec2:CreateSecurityGroup action. Encoded
authorization failure message: Q2xpY2s...
```

**Cause:** the identity Terraform runs as (the assumed role) has no
policy that allows `ec2:CreateSecurityGroup`. Plan succeeded because
`ReadOnlyAccess` allows the `Describe*` calls that plan makes.

**Investigate:**

1. Who am I? `aws sts get-caller-identity` (for the provider, look
   for `AssumeRole` and the role ARN in a `TF_LOG=DEBUG` log).
2. Decode the message (as your admin profile, which has
   `sts:DecodeAuthorizationMessage`):

   ```bash
   aws sts decode-authorization-message \
     --encoded-message "Q2xpY2s..." \
     --query DecodedMessage --output text | jq .
   ```

3. CloudTrail → Event history, filter **Event name** =
   `CreateSecurityGroup`; the event shows `errorCode`
   `Client.UnauthorizedOperation` and the role session.

**Fix:** grant the missing action to the role Terraform uses (least
privilege: add `ec2:CreateSecurityGroup` and friends, not
`AdministratorAccess`), or run as the right identity. For the lab,
simply unset `TF_VAR_role_arn` and remove the `assume_role` block.

**Teardown:** `terraform destroy` here (nothing was created), then
`terraform -chdir=setup destroy`, then
`../../../scripts/check-leftovers.sh 20`.
