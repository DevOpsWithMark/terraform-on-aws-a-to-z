# 02-cycle

**Break:** `terraform init && terraform validate` (or `plan`)

```text
Error: Cycle: aws_security_group.db, aws_security_group.app
```

**Cause:** `app` needs the ID of `db` (egress rule), and `db` needs
the ID of `app` (ingress rule). Terraform builds a dependency graph
and refuses to walk a loop.

**Fix:** create both groups with no inline rules, then attach the
rules as separate resources. The groups no longer depend on each
other; each rule depends on both groups.

```hcl
resource "aws_security_group" "app" {
  name   = "devopswm-ch20-app"
  vpc_id = data.aws_vpc.default.id
}

resource "aws_security_group" "db" {
  name   = "devopswm-ch20-db"
  vpc_id = data.aws_vpc.default.id
}

resource "aws_vpc_security_group_egress_rule" "app_to_db" {
  security_group_id            = aws_security_group.app.id
  referenced_security_group_id = aws_security_group.db.id
  ip_protocol                  = "tcp"
  from_port                    = 5432
  to_port                      = 5432
}

resource "aws_vpc_security_group_ingress_rule" "db_from_app" {
  security_group_id            = aws_security_group.db.id
  referenced_security_group_id = aws_security_group.app.id
  ip_protocol                  = "tcp"
  from_port                    = 5432
  to_port                      = 5432
}
```

To see the loop, run `terraform graph -type=plan | grep -i cycle`
or render the graph and look for the two nodes pointing at each
other.

**Teardown:** `terraform destroy` (security groups are free), then
`../../../scripts/check-leftovers.sh 20`.
