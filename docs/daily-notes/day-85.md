# Day 85 — ECS Architecture, Terraform Foundation, State, and OIDC

## What I Did

* Created the standalone Week 13 FastApi application and Terraform repository structure.
* Configured the required Terraform and AWS provider versions.
* Added reusable variables and defined `local.name_prefix` and `local.common_tags`.
* Configured an isolated S3 backend key with encryption and S3-native state locking.
* Reused the existing GitHub Actions OIDC provider through a Terraform data source.
* Defined a new IAM deployment role scoped to this repository and the `main` branch.
* Added outputs for the deployment-role ARN, OIDC provider ARN, and trusted OIDC subject.
* Ran `terraform fmt -check`, `terraform init`, `terraform validate`, and a safety plan.
* Confirmed the Day 85 plan contained only the repository-specific IAM role.
* Created the clean Week 13 baseline Git commit.

## What I Learned

* An ECS cluster groups services and tasks, while a service maintains the required number of running tasks.
* Fargate runs ECS containers without requiring me to manage EC2 container hosts.
* Terraform data sources read existing AWS resources without creating or owning them.
* The OIDC provider establishes AWS trust, while the IAM role defines who can authenticate and what they can do.
* Repository-scoped OIDC trust restricts role assumption to the approved repository and branch.
* The task execution role allows ECS to pull images, write logs, and retrieve secrets.
* The task role allows the running application to access permitted AWS services.
* A unique backend key prevents Week 13 state from conflicting with previous Terraform projects.
* OIDC and least-privilege IAM remove the need for long-lived AWS credentials in GitHub.

## Day 85 Outcome

The Terraform, remote-state, and authentication foundation was established without creating ECS, ECR, ALB, RDS, VPC, or other cost-generating application infrastructure.
