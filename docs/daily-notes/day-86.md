# Day 86 — Minimal Networking, Security Groups, and ECR

## What I Did

* Built a reusable VPC module with two public subnets and two private database subnets across two Availability Zones.
* Added an Internet Gateway, public and private route tables, and the required subnet associations.
* Kept the design cost-aware by creating no NAT Gateway.
* Created separate security groups for the ALB, ECS tasks, and RDS.
* Restricted traffic to `Internet → ALB:80 → ECS:8000 → RDS:5432`.
* Created a new Week 13 ECR repository managed only by the Week 13 Terraform state.
* Enabled immutable tags, scan-on-push, AES-256 encryption, and an image lifecycle policy.
* Applied the Terraform foundation and verified the outputs and final no-drift plan.
* Built the FastAPI image for `linux/amd64`, tagged it with the full Git SHA, and pushed it to ECR.
* Recorded the image digest and reviewed the ECR scan status.

## What I Learned

* Fargate uses `awsvpc` networking, which gives every task its own ENI, private IP address, and security groups.
* Public subnets provide internet routing, while private database subnets have no direct internet route.
* Security-group references are safer than fixed IP rules because access follows the approved resource groups.
* One Terraform state should have clear ownership of each ECR repository.
* Immutable Git-SHA tags improve deployment traceability and prevent image tags from being overwritten.
* ECR lifecycle policies automatically remove old or untagged images and reduce storage costs.
* A cost-aware lab can avoid NAT Gateway charges while still restricting direct inbound access to ECS tasks.

## What Broke and How I Fixed It

* No major runtime or infrastructure failure was recorded during Day 86.
* Terraform formatting, module initialization, and resource-reference issues were prevented or corrected using `terraform fmt`, `terraform init`, and `terraform validate`.
* I reviewed the Terraform plan before applying it to confirm that no NAT Gateway, ALB, ECS service, or RDS instance was being created prematurely.
* I used ECR scan-status checks and the image digest to verify the pushed artifact instead of relying only on the image tag.

## Day 86 Outcome

The minimal VPC, subnet, routing, security-group, and ECR foundation is ready for the private RDS, ALB, and ECS Fargate stages. The initial immutable application image is available in ECR for use by the future ECS task definition.
