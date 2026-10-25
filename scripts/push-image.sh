#!/usr/bin/env bash
# scripts/push-image.sh
# Copies the pre-built app image into your ECR repository.
# Run from an environment folder (envs/dev or envs/prod)
# after the first apply has created the repository:
#   ../../scripts/push-image.sh
set -euo pipefail

source_image="${SOURCE_IMAGE:-ghcr.io/devopswithmark/shortener:1.0.0}"
tag="${source_image##*:}"
repo_url="$(terraform output -raw ecr_repository_url)"
registry="${repo_url%%/*}"
region="$(cut -d. -f4 <<<"$registry")"

echo "Copying $source_image -> $repo_url:$tag"
aws ecr get-login-password --region "$region" |
  docker login --username AWS --password-stdin "$registry"

docker pull --platform linux/amd64 "$source_image"
docker tag "$source_image" "$repo_url:$tag"
docker push "$repo_url:$tag"

echo "Done. Image: $repo_url:$tag"
