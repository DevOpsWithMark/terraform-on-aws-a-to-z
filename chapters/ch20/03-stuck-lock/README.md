# 03-stuck-lock

Needs the Chapter 11 state bucket and `backend.hcl` in the repo root.

**Break:**

1. Terminal 1:
   `terraform init -backend-config=../../../backend.hcl`, then
   `terraform apply`. Leave it waiting at `Enter a value:`.
   Terraform holds the lock while it waits.
2. Terminal 2: `terraform plan` fails with the lock error below.
3. Terminal 2: simulate a crash of terminal 1 with
   `pkill -9 -f "terraform apply"`. The lock file stays behind.

```text
Error: Error acquiring the state lock

Error message: operation error S3: PutObject, https response
error StatusCode: 412, ... api error PreconditionFailed: At
least one of the pre-conditions you specified did not hold
Lock Info:
  ID:        9db590f1-b6fe-c5f2-2678-8804f089deba
  Path:      devopswm-shortener-tfstate/lab/ch20/terraform.tfstate
  Operation: OperationTypeApply
  Who:       you@laptop
  Version:   1.17.0
  Created:   2026-10-14 17:02:11.513 +0000 UTC
```

**Cause:** another run holds the lock, or a run died before it could
delete `lab/ch20/terraform.tfstate.tflock` from the bucket.

**Fix:**

1. Make sure no run is still active (the `Who` and `Created` fields,
   your CI runs, your teammates).
2. `terraform force-unlock 9db590f1-b6fe-c5f2-2678-8804f089deba`
   (use the ID from your own error) and answer `yes`.
3. Run `terraform plan` again.

Never use `-lock=false` to get around a lock you do not understand.

**Teardown:** `terraform destroy`, then delete the state object:
`aws s3 rm s3://<bucket>/lab/ch20/terraform.tfstate`.
