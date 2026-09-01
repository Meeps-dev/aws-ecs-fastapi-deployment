output "cluster_name" {
  value = aws_ecs_cluster.this.name
}

output "cluster_arn" {
  value = aws_ecs_cluster.this.arn
}

output "task_definition_arn" {
  value = aws_ecs_task_definition.api.arn
}

output "task_definition_revision" {
  value = aws_ecs_task_definition.api.revision
}

output "execution_role_name" {
  value = aws_iam_role.execution.name
}

output "execution_role_arn" {
  value = aws_iam_role.execution.arn
}

output "task_role_name" {
  value = aws_iam_role.task.name
}

output "task_role_arn" {
  value = aws_iam_role.task.arn
}

output "log_group_name" {
  value = aws_cloudwatch_log_group.this.name
}

output "container_name" {
  value = var.container_name
}
