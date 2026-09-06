# ECS Service Auto Scaling Decision

## Current Decision

ECS Service Auto Scaling is not enabled in the Week 13 development environment.

The service uses:

- Desired count: `1`
- Deployment minimum healthy percentage: `100`
- Deployment maximum percentage: `200`

This allows one replacement task to run temporarily during a rolling deployment
without leaving an unrestricted scaling policy active.

## Production Approach

For a production workload, register the ECS service as an Application Auto
Scaling target and configure:

- Minimum capacity: `2`
- Maximum capacity: workload-dependent
- Target-tracking metric: average CPU, average memory, or ALB requests per target
- Scale-out cooldown
- Scale-in cooldown

When Auto Scaling owns the desired count, Terraform should ignore external
changes to `desired_count` on the ECS service.

## Cost Decision

Auto Scaling was documented but not enabled to prevent the lab from increasing
its Fargate task count unexpectedly.
