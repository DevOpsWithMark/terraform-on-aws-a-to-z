#!/usr/bin/env bash
# scripts/check-leftovers.sh
# Lists AWS resources still carrying a Chapter tag (every lab
# resource has one), optionally only Chapter=<n>. Run it after
# every teardown.
#   ./scripts/check-leftovers.sh        # whole book
#   ./scripts/check-leftovers.sh 5      # Chapter 5 only
set -euo pipefail

chapter="${1:-}"

if [[ -n "$chapter" ]]; then
  filters=("Key=Chapter,Values=$chapter")
else
  filters=(Key=Chapter)
fi

# Deleted ECS clusters and task definitions stay visible as
# INACTIVE for a while. They cost nothing and cannot be
# deleted, so skip them.
still_active() {
  local arn status
  while read -r arn; do
    [[ -z "$arn" ]] && continue
    status=ACTIVE
    case "$arn" in
      *:ecs:*:cluster/*)
        status=$(aws ecs describe-clusters --region "$1" \
          --clusters "$arn" --query 'clusters[0].status' \
          --output text) ;;
      *:ecs:*:task-definition/*)
        status=$(aws ecs describe-task-definition --region "$1" \
          --task-definition "$arn" \
          --query 'taskDefinition.status' --output text) ;;
    esac
    [[ "$status" == "INACTIVE" ]] || echo "$arn"
  done
}

for r in us-east-1 us-west-2; do
  arns=$(aws resourcegroupstaggingapi get-resources \
    --region "$r" --tag-filters "${filters[@]}" \
    --query 'ResourceTagMappingList[].ResourceARN' \
    --output text | tr '\t' '\n' | still_active "$r")
  if [[ -n "$arns" && "$arns" != "None" ]]; then
    echo "Still tagged in $r:"
    sed 's/^/  /' <<<"$arns"
    found=1
  fi
done

# IAM roles and OIDC providers are global and may not show up in
# the tagging API, so check their names directly.
roles=$(aws iam list-roles --query \
  "Roles[?starts_with(RoleName,'devopswm-')].RoleName" \
  --output text)
if [[ -n "$roles" && "$roles" != "None" ]]; then
  echo "IAM roles still present:"
  tr '\t' '\n' <<<"$roles" | sed 's/^/  /'
  found=1
fi

# The GitHub (Chapter 18) and HCP Terraform (Chapter 19) OIDC
# providers carry no devopswm- name, so match their URLs.
oidc=$(aws iam list-open-id-connect-providers --query \
  'OpenIDConnectProviderList[].Arn' --output text |
  tr '\t' '\n' |
  grep -E 'githubusercontent.com|app.terraform.io' ||
  true)
if [[ -n "$oidc" ]]; then
  echo "IAM OIDC providers still present:"
  sed 's/^/  /' <<<"$oidc"
  found=1
fi

if [[ -z "${found:-}" ]]; then
  echo "Nothing left. Teardown complete."
else
  echo
  echo "Note: the tagging API can lag a few minutes after"
  echo "a delete. Run again before deleting by hand."
  exit 1
fi
