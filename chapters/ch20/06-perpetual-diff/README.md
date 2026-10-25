# 06-perpetual-diff

**Break:** `terraform init && terraform apply`, then `terraform plan`.
The plan right after a successful apply shows changes:

```text
  # aws_security_group.web will be updated in-place
  ~ resource "aws_security_group" "web" {
      ~ ingress = [
          - {
              - from_port   = 443
              ...
            },
            # (1 unchanged element hidden)
        ]
      ~ tags    = {
          ~ "LastApplied" = "2026-10-14T17:20:05Z"
              -> (known after apply)
        }
        # (8 unchanged attributes hidden)
    }

Plan: 0 to add, 1 to change, 0 to destroy.
```

Apply it, and the next plan wants to create
`aws_vpc_security_group_ingress_rule.https` again (the group update
deleted it). The two plans alternate forever.

**Cause 1:** `timestamp()` returns a new value on every run, so the
tag always differs.

**Cause 2:** the inline `ingress` block is authoritative: it removes
any rule not listed in it. The separate
`aws_vpc_security_group_ingress_rule` adds port 443 back. The two
resources fight forever.

**Fix:** run `terraform destroy` first: removing the inline block
does not delete its rule in AWS, so the new port-80 rule would fail
with `InvalidPermission.Duplicate`. Then:

1. Drop the `timestamp()` tag (or, if you must keep a creation time,
   add `lifecycle { ignore_changes = [tags["LastApplied"]] }`).
2. Pick one style for rules. Move port 80 into its own
   `aws_vpc_security_group_ingress_rule` and delete the inline
   `ingress` block.

Run `terraform apply` once more, then `terraform plan`. It should say
`No changes.`

Other common sources: JSON policies written as strings with a
different key order or whitespace (use `jsonencode` or
`aws_iam_policy_document`), and values that AWS normalizes (case,
trailing dots, default values you did not set).

**Teardown:** `terraform destroy`, then
`../../../scripts/check-leftovers.sh 20`.
