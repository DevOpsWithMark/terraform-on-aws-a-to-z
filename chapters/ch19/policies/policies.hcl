# chapters/ch19/policies/policies.hcl
# Policy set configuration for a VCS-connected OPA policy set
# (paid editions). On the Free edition, paste the .rego file
# into the UI instead and use the same query.
policy "s3-project-tag" {
  query             = "data.terraform.s3_project_tag.deny"
  enforcement_level = "mandatory"
}
