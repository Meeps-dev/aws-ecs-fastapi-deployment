# ECS Deployment Rollback

## Automatic Rollback

The ECS service has the deployment circuit breaker enabled with rollback.

When a new deployment cannot reach a healthy steady state, ECS can return the
service to the last completed deployment.

## Manual Rollback

1. Identify the previous working task-definition ARN.
2. Update the ECS service to that revision.
3. Wait for the service to stabilize.
4. Confirm ALB target health.
5. Retest the API.

### update service.
aws ecs update-service \
  --cluster "$CLUSTER_NAME" \
  --service "$SERVICE_NAME" \
  --task-definition "$PREVIOUS_TASK_DEFINITION"

aws ecs wait services-stable \
  --cluster "$CLUSTER_NAME" \
  --services "$SERVICE_NAME"

### verification.
aws ecs describe-services \
  --cluster "$CLUSTER_NAME" \
  --services "$SERVICE_NAME"

aws elbv2 describe-target-health \
  --target-group-arn "$TARGET_GROUP_ARN"

During a rolling update, the minimum healthy percentage sets the lower bound of healthy tasks, while the maximum percentage controls how many old and new tasks may exist temporarily. With desired count `1` and `100/200`, ECS can start one replacement task while retaining the current task until the replacement becomes healthy.

