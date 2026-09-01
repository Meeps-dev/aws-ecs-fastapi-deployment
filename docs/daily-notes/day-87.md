# Day 87 — Private RDS, Secrets, and Database Migration Strategy

## What I Did

* Created an RDS DB subnet group using two private database subnets across two Availability Zones.
* Provisioned an encrypted, single-AZ PostgreSQL RDS instance with public access disabled.
* Restricted PostgreSQL traffic on port `5432` to the ECS security group only.
* Stored the database URL, database password, and application secrets as SSM Parameter Store `SecureString` values.
* Kept real secrets, `.env` files, `terraform.tfvars`, plans, and state files out of Git.
* Exposed only secret names and ARNs for the future ECS task definition.
* Documented Alembic migrations as a one-off Fargate task that must complete before the ECS service deployment.
* Ran Terraform formatting, initialization, validation, planning, apply, and final drift checks.

## What I Learned

* A DB subnet group allows RDS to use private subnets across multiple Availability Zones.
* ECS connects to RDS through the private RDS endpoint, not `localhost` or a Docker Compose service name.
* Security-group referencing provides controlled `ECS SG → RDS SG` database access.
* The ECS task execution role retrieves secrets referenced during container startup.
* SSM Parameter Store is a cost-aware option for encrypted configuration, while Secrets Manager provides advanced secret-rotation features.
* Marking a Terraform value as `sensitive` hides it from normal output but does not automatically remove it from state.
* Database migrations should run once as a controlled deployment step, not independently from every API container.

## What Broke and How I Fixed It

* Directly running Alembic from my local machine was unsuitable because RDS was intentionally private.
* I kept the database private and selected a one-off Fargate migration task using the same image, network, security group, and SSM-injected `DATABASE_URL`.
* I addressed the risk of exposing secret values by using encrypted SSM parameters, protected Terraform state, ignored local secret files, and secret ARN references instead of hardcoded values.
* No major RDS runtime failure was recorded during Day 87; migration execution will be completed after the ECS task definition and CloudWatch logging are available.

## Day 87 Outcome

A private PostgreSQL database and secure configuration foundation are ready for ECS. The application secrets are stored outside Git, and the controlled Alembic migration strategy is prepared for the next ECS deployment stage.
