# 01-bad-reference

**Break:** `terraform init && terraform validate`

```text
Error: Reference to undeclared resource

  on main.tf line 32, in resource "aws_s3_bucket_versioning" "log":
  32:   bucket = aws_s3_bucket.logs.id

A managed resource "aws_s3_bucket" "logs" has not been declared
in the root module.
```

**Cause:** the bucket is declared as `aws_s3_bucket.log`, but the
versioning resource refers to `aws_s3_bucket.logs`. Terraform checks
every reference against the declared names before it talks to AWS.

**Fix:** change line 32 to `bucket = aws_s3_bucket.log.id`, then run
`terraform validate` again. Related errors with the same cure:
"Unsupported attribute" (a typo after the dot, such as `.idd`) and
"Reference to undeclared input variable" (`var.` name typo).

**Teardown:** nothing was created if you only ran `validate`. If you
applied after fixing, run `terraform destroy`.
