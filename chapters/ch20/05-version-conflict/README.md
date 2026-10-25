# 05-version-conflict

**Break:** `terraform init`

```text
Error: Failed to query available provider packages

Could not retrieve the list of available versions for provider
hashicorp/aws: no available releases match the given
constraints ~> 5.0, ~> 6.0
```

**Cause:** Terraform installs one version of each provider for the
whole configuration. It merges every `required_providers` constraint
(root and all modules) and finds no version that is both 5.x and 6.x.
`terraform providers` prints the tree and shows which module asks
for what.

**Fix:** a module should state the *minimum* it needs, and let the
root choose the exact range. Change the module to:

```hcl
aws = {
  source  = "hashicorp/aws"
  version = ">= 5.0"
}
```

Then run `terraform init`. If a lock file already pinned an older
version (error "locked provider ... does not match configured
version constraint"), run `terraform init -upgrade` to choose a new
one and commit the updated `.terraform.lock.hcl`.

For a registry module, upgrade to a module version that supports
provider 6, or fork it.

**Teardown:** if you applied after fixing, `terraform destroy`, then
`../../../scripts/check-leftovers.sh 20`.
