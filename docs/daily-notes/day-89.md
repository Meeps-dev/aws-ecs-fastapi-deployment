# Day 89 — Application Load Balancer and Running ECS Service

## What I Did

* Created a public Application Load Balancer across two public subnets.
* Created an `ip` target group on port `8000` with `/health` checks.
* Added an HTTP listener on port `80` and forwarded traffic to the ECS target group.
* Created an ECS Fargate service with a desired count of `1`.
* Connected the service to the ALB target group and enabled the deployment circuit breaker with rollback.
* Used public task networking without a NAT Gateway while allowing inbound traffic only from the ALB security group.
* Added root Terraform outputs for the ALB and ECS service.
* Checked service counts, target health, API endpoints, and CloudWatch application logs.

## What I Learned

* An ALB listener receives traffic and forwards it to a target group.
* Fargate tasks use `ip` targets because each task receives its own ENI and private IP address.
* ALB health checks determine whether a task is ready to receive traffic.
* An ECS service maintains the configured desired task count and replaces failed or unhealthy tasks.
* ECS service events are useful for diagnosing task placement, startup, and health-check failures.
* A public task IP provides outbound access but does not allow direct inbound access when security groups are restricted.

## What Broke and How I Fixed It

* Terraform could not find `ecs_service_name` because the root output was not yet saved in the active state.
* I added the missing environment-level outputs, created a fresh reconciliation plan, and applied it to update the state.
* A previous interrupted Terraform operation left a stale S3 state lock and caused a `412 PreconditionFailed` error.
* I confirmed no Terraform process was active, removed the stale lock with `terraform force-unlock`, and reran the plan with a lock timeout.
* Guarded output loading prevented empty Terraform values from being passed to AWS CLI commands.

## Day 89 Outcome

The public ALB and ECS Fargate service configuration was established, the service was connected to the IP target group, and the Terraform output and remote-state lock issues were resolved.
