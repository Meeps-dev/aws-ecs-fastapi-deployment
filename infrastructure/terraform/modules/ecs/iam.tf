resource "aws_iam_role" "execution" {
  name               = "${var.name_prefix}-ecs-execution"
  description        = "ECS agent access to application images, logs, and runtime parameters"
  assume_role_policy = data.aws_iam_policy_document.ecs_assume_role.json

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-ecs-execution"
  })
}

resource "aws_iam_role_policy" "execution" {
  name   = "runtime-access"
  role   = aws_iam_role.execution.id
  policy = data.aws_iam_policy_document.execution_permissions.json
}

resource "aws_iam_role" "task" {
  name               = "${var.name_prefix}-ecs-task"
  description        = "Application task identity; no application AWS permissions attached initially"
  assume_role_policy = data.aws_iam_policy_document.ecs_assume_role.json

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-ecs-task"
  })
}
