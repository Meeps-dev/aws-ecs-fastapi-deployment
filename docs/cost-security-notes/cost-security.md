# ECS — Cost and Security Notes

## Cost Decisions

* Used one ECS Fargate task with `0.25 vCPU` and `512 MiB`.
* Kept Container Insights and Service Auto Scaling disabled for the lab.
* Created no NAT Gateway; the task used a public subnet with restricted inbound access.
* Used one small, single-AZ PostgreSQL RDS instance with `20 GiB` storage.
* Set CloudWatch log retention to three days.
* Limited ECR storage with immutable tags and lifecycle rules for old and untagged images.
* Used SSM Parameter Store Standard tier for application secrets.
* Tagged resources with the project, week, owner, environment, and Terraform ownership.
* Planned Terraform teardown after capturing all deployment and failure evidence.

## Security Decisions

* Reused the existing GitHub OIDC provider instead of storing AWS access keys in GitHub.
* Restricted OIDC role assumption to the approved repository and `main` branch.
* Separated the GitHub plan role, deployment role, ECS execution role, and application task role.
* Applied least-privilege access to ECR, CloudWatch Logs, SSM, ECS, and `iam:PassRole`.
* Stored secrets in SSM `SecureString` parameters and committed no secret values to Git.
* Kept RDS private and allowed PostgreSQL access only from the ECS security group.
* Allowed ECS application traffic only from the ALB security group.
* Used immutable Git-SHA tags and digest-pinned ECS image references.
* Encrypted and isolated Terraform remote state with S3-native locking.
* Kept the application container running as a non-root user.

## Production Improvements

* Place ECS tasks in private application subnets with VPC endpoints or controlled NAT access.
* Add HTTPS with ACM, Route 53, WAF, alarms, ALB access logs, and production log retention.
* Use Multi-AZ RDS, managed secret rotation, automatic scaling, and stricter deployment approvals.
