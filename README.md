# terraform-on-aws-a-to-z

Lab code for *Terraform on AWS, A to Z* (DevOps With Mark Series).
Short link printed in the book: **devopswithmark.com/terraform**.

## What's here

```
app/                 URL Shortener: Node.js + Express API, static frontend
  server.js          API: POST /api/links, GET /api/links/:code,
                     DELETE /api/links/:code (x-admin-token),
                     GET /r/:code (301 redirect), GET /healthz
  public/            index.html, app.js, style.css (served by CloudFront)
  Dockerfile         image published as ghcr.io/devopswithmark/shortener:1.0.0
bootstrap/           Ch 11: S3 state bucket (local state, prevent_destroy)
modules/
  network/           Ch 14: VPC, 2 AZs, public/private subnets, 1 NAT,
                     S3 + DynamoDB gateway endpoints
  static-site/       Ch 13/15: private S3 bucket + CloudFront (OAC);
                     optional API origin for /api/* and /r/*
  service/           Ch 15: ECR, DynamoDB, ephemeral admin token in
                     Secrets Manager (write-only), ALB (CloudFront-only
                     ingress), ECS Fargate service, IAM, logs
envs/
  dev/               Ch 15: network + service + site, state key
                     shortener/dev/terraform.tfstate
  prod/              Ch 16: same modules, 10.1.0.0/16, PITR on,
                     30-day logs, state key shortener/prod/...
chapters/chNN/       practice labs for Chapters 3-12, 16, 19, 20
cicd/                Ch 18: GitHub OIDC provider + plan/apply roles
infracost.yml        Ch 21: projects for infracost scan (run from here)
.github/workflows/   Ch 18: plan on pull request, apply on merge
scripts/
  check-leftovers.sh lists resources still tagged Chapter[=n]
  push-image.sh      copies the pre-built image into your ECR repo
```

## Conventions

- Region `us-east-1` (Chapter 4 also uses `us-west-2`).
- Terraform `>= 1.12` (book written on 1.17.x); AWS provider `~> 6.0`;
  random provider `~> 3.7` (Chapter 9 and the service module).
- Every resource carries default tags `Chapter=<n>`,
  `ManagedBy=terraform` (+ `Project=shortener`, `Environment=<env>` in envs/).
- Every resource name starts with `devopswm-` (DevOps With Mark): the app uses
  `devopswm-shortener-<env>-<name>`, practice labs `devopswm-chNN-<name>`.
- S3 bucket names are globally unique, so you choose them: replace each
  `"<your bucket name>"` placeholder (inline, or in `terraform.tfvars`), e.g.
  `devopswm-labs-ex1`. If a name is taken, add your initials.
- Remote state: S3 backend, `use_lockfile = true`, bucket name passed with
  `terraform init -backend-config=../../backend.hcl` (see `backend.hcl.example`).

## Running the app (Chapter 15 summary)

```bash
cd envs/dev
terraform init -backend-config=../../backend.hcl
terraform apply -var desired_count=0   # creates ECR, network, etc.
../../scripts/push-image.sh            # copy image into ECR
terraform apply                        # desired_count = 2
terraform output app_url               # open in a browser
```

Tear down with `terraform destroy`, then `../../scripts/check-leftovers.sh`.

## License

MIT (see `LICENSE`). Not affiliated with HashiCorp, IBM, or Amazon Web Services.
