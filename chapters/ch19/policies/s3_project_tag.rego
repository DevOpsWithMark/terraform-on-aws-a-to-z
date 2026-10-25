# chapters/ch19/policies/s3_project_tag.rego
# Deny any S3 bucket that would be created or updated
# without a Project tag (set directly or by default_tags).
package terraform.s3_project_tag

import rego.v1

deny contains msg if {
    some rc in input.plan.resource_changes
    rc.type == "aws_s3_bucket"
    some action in rc.change.actions
    action in {"create", "update"}
    not has_project_tag(rc.change.after)
    msg := sprintf("%s has no Project tag", [rc.address])
}

has_project_tag(after) if after.tags_all.Project
has_project_tag(after) if after.tags.Project
