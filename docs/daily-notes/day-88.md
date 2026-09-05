# Day 88 — ECS Cluster, IAM Roles, Logs, and Task Definition

## What I Did

* Created an ECS cluster with Container Insights disabled for cost control.
* Created a CloudWatch log group with a three-day retention period.
* Created separate ECS task execution and application task roles.
* Granted the execution role least-privilege access to ECR, CloudWatch Logs, and the required SSM parameters.
* Registered an ECS Fargate task definition using `awsvpc`, `256` CPU units, `512 MiB` memory, Linux/X86_64, and port `8000`.
* Pinned the container image to its immutable ECR SHA-256 digest.
* Injected non-secret environment variables and referenced encrypted SSM parameters for secrets.
* Configured the `awslogs` driver and added root Terraform outputs for ECS verification.
* Prepared the task definition for the controlled one-off Alembic migration and the Day 89 ECS service.

## What I Learned

* An ECS cluster is the logical boundary that contains tasks and services.
* Fargate tasks move through states such as `PROVISIONING`, `PENDING`, `RUNNING`, and `STOPPED`.
* Updating a task definition creates a new revision within the same task-definition family.
* The execution role is used by ECS to pull images, retrieve secrets, and publish logs.
* The task role is used only when the running application calls AWS services.
* Fargate requires `awsvpc` networking and a supported CPU-and-memory combination.
* A port mapping exposes the container port to ECS networking, but the application must still listen on that port.
* Digest pinning guarantees that ECS runs the exact image content selected for deployment.

## What Broke and How I Fixed It

* The terminal exited before resolving the image digest because Bash-style `read -p` syntax was used in Zsh.
* I fixed it by assigning the existing Git-SHA tag directly and resolving the digest with `aws ecr describe-images`.
* Terraform reported that the ECS outputs were missing from state because the child-module outputs were not available as saved root outputs.
* I fixed this by exposing the ECS module values in the environment-level `outputs.tf` and applying a fresh output-only plan.
* The failed output lookup left `CLUSTER_NAME` empty, which caused an invalid ECS cluster request.
* I added guarded variable loading so AWS commands run only after every Terraform output is successfully retrieved.

## Day 88 Outcome

The ECS cluster, least-privilege IAM roles, CloudWatch logging, and digest-pinned Fargate task definition are ready. The next stage is to run the controlled database migration and deploy the ECS service behind the Application Load Balancer.
