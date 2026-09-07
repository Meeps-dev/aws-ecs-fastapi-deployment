# AWS ECS Fargate FastAPI Deployment

## Overview

This project deploys a Dockerized FastAPI users/posts API to **Amazon ECS on AWS Fargate** behind an **Application Load Balancer**, with data stored in a **private PostgreSQL RDS instance**.

The infrastructure is managed with Terraform, container images are stored in Amazon ECR, application secrets are loaded from SSM Parameter Store, and GitHub Actions performs CI checks and immutable rolling deployments through AWS OIDC.

## Architecture

```text
Pull Request
    |
    v
GitHub Actions Quality Gates
    |
    +-- Python lint and tests
    +-- Docker linux/amd64 build validation
    +-- Terraform fmt and validate
    |
Merge to main
    |
    v
GitHub Actions + AWS OIDC
    |
    v
Amazon ECR
Immutable Git-SHA tag + SHA-256 digest
    |
    v
ECS Task Definition Revision
    |
    v
ECS Fargate Service
    |
    v
Application Load Balancer
    |
    v
FastAPI Application
    |
    v
Private PostgreSQL RDS

SSM Parameter Store --> ECS task secrets
Container stdout/stderr --> CloudWatch Logs
Terraform state --> Encrypted S3 backend with native locking
```

## AWS Services and Tools

* Amazon ECS and AWS Fargate
* Amazon ECR
* Application Load Balancer
* Amazon RDS for PostgreSQL
* Amazon CloudWatch Logs
* AWS Systems Manager Parameter Store
* AWS IAM and GitHub OIDC
* Amazon VPC and Security Groups
* Amazon S3 remote Terraform state
* Terraform, Docker, FastAPI, Alembic, PostgreSQL, and GitHub Actions

## Implementation Summary

* Created a dedicated VPC with two public subnets and two private database subnets across two Availability Zones.
* Avoided a NAT Gateway for this cost-aware development environment.
* Deployed the ALB and Fargate tasks in public subnets while allowing application traffic only from the ALB security group.
* Kept RDS private and allowed PostgreSQL traffic only from the ECS security group.
* Created a private ECR repository with immutable tags, scan-on-push, AES-256 encryption, and lifecycle rules.
* Pinned ECS deployments to image SHA-256 digests rather than mutable tags.
* Created separate ECS task execution and application task roles.
* Configured a Fargate task with `256` CPU units, `512 MiB` memory, `awsvpc` networking, and container port `8000`.
* Stored runtime secrets as SSM `SecureString` parameters and referenced only their ARNs in the task definition.
* Sent container logs to CloudWatch with a three-day retention period.
* Ran Alembic migrations as a controlled one-off Fargate task.
* Created an ECS service with desired count `1`, ALB health checks, and deployment circuit-breaker rollback.

## CI/CD Workflows

### `ci.yml`

Runs on pull requests:

* Python linting and tests
* PostgreSQL-backed migration validation
* Docker `linux/amd64` build validation
* Terraform formatting and validation
* No AWS credentials, ECR push, or ECS deployment

### `terraform-plan.yml`

Runs a remote-state Terraform plan through a least-privilege OIDC role.

* Performs no automatic `terraform apply`
* Reads the existing infrastructure and state safely
* Reports proposed infrastructure changes

### `deploy-ecs.yml`

Runs on approved changes to `main`:

* Authenticates to AWS through OIDC
* Builds a new `linux/amd64` image
* Tags the image with the full Git commit SHA
* Pushes the image to ECR
* Resolves the image digest
* Registers a new task-definition revision
* Updates the ECS service
* Waits for stabilization
* Confirms the new target is healthy
* Confirms the previous task stops
* Verifies the API through the ALB

## Security Decisions

* Used GitHub OIDC instead of long-lived AWS access keys.
* Restricted role assumption to the approved repository and `main` branch.
* Applied least-privilege permissions to planning, deployment, image publishing, logging, and secret retrieval.
* Separated the GitHub plan role, GitHub deployment role, ECS execution role, and ECS task role.
* Stored no real secret values in Git or GitHub Actions.
* Kept RDS publicly inaccessible.
* Restricted traffic to `Internet → ALB:80 → ECS:8000 → RDS:5432`.
* Used immutable image tags and digest-pinned task definitions.
* Encrypted and isolated Terraform state with S3-native state locking.
* Ran the application container as a non-root user.

## Cost Controls

* No NAT Gateway
* One Fargate task at `0.25 vCPU` and `512 MiB`
* Container Insights disabled
* Service Auto Scaling disabled for the lab
* Small, single-AZ RDS instance
* Three-day CloudWatch log retention
* ECR lifecycle policy for old and untagged images
* SSM Parameter Store Standard tier
* Terraform-managed teardown after capturing project evidence

## Intentional Failure and Recovery

A task-definition revision was registered with the nonexistent ECR tag:

```text
tag-does-not-exist
```

The replacement task failed with an image-pull error. The investigation covered:

* ECS service events
* Stopped-task reason
* Container reason and exit state
* ECR image tags
* CloudWatch log-stream availability
* IAM permissions
* ALB target health

The service retained its existing healthy task, the failed deployment was rolled back, and a corrected revision using the known-good image digest restored a stable `1/1` service with a healthy ALB target.

## ECS Fargate Compared with EC2

ECS Fargate removes the need to provision, patch, and scale container-host EC2 instances. The deployment unit is a versioned task definition rather than a server or AMI.

ECS on EC2 provides greater host-level control, but it also requires instance maintenance, capacity planning, patching, and operating-system management.

## Repository Structure

```text
.
├── application/                    # FastAPI application, tests, Docker and Alembic
├── infrastructure/terraform/
│   ├── environments/dev/           # Development environment composition
│   └── modules/                    # VPC, security, ECR, RDS, ALB and ECS modules
├── .github/workflows/              # CI, Terraform plan and ECS deployment
├── docs/
│   ├── architecture/
│   ├── cost-security-notes/
│   ├── daily-notes/
│   ├── decisions/
│   ├── evidence/
│   ├── runbooks/
│   ├── screenshots/
│   └── troubleshooting/
└── scripts/
```

## Project Evidence

The repository includes proof of:

* ECS cluster and Fargate task definition
* Running ECS service
* Healthy ALB target and successful `/health` response
* Private RDS connectivity through database-backed API endpoints
* CloudWatch container logs
* Immutable ECR image versions
* Successful GitHub Actions workflows
* Rolling task-definition deployment
* Intentional stopped-task failure and recovery
* Cost, security, rollback, and troubleshooting decisions

## Production Improvements

For a production environment, I would:

* Place ECS tasks in private application subnets.
* Add controlled NAT access or VPC endpoints.
* Enable HTTPS using ACM.
* Add Route 53 and AWS WAF.
* Use Multi-AZ RDS.
* Configure CloudWatch alarms and longer production log retention.
* Enable managed secret rotation.
* Introduce cost-capped ECS Service Auto Scaling.
* Add stricter deployment approvals and environment protection rules.
