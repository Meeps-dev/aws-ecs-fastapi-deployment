resource "aws_ecs_cluster" "this" {
  name = "${var.name_prefix}-cluster"

  setting {
    name  = "containerInsights"
    value = "disabled"
  }

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-cluster"
  })
}

resource "aws_cloudwatch_log_group" "this" {
  name              = var.log_group_name
  retention_in_days = 3
  log_group_class   = "STANDARD"

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-application-logs"
  })
}

resource "aws_ecs_task_definition" "api" {
  family                   = "${var.name_prefix}-api"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"

  cpu    = "256"
  memory = "512"

  execution_role_arn = aws_iam_role.execution.arn
  task_role_arn      = aws_iam_role.task.arn

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }

  container_definitions = jsonencode([
    {
      name      = var.container_name
      image     = var.container_image
      essential = true

      portMappings = [
        {
          containerPort = var.container_port
          protocol      = "tcp"
        }
      ]

      environment = [
        for name, value in var.environment : {
          name  = name
          value = value
        }
      ]

      secrets = [
        for name, parameter_arn in var.secret_parameter_arns : {
          name      = name
          valueFrom = parameter_arn
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"

        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.this.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs"
          "mode"                  = "non-blocking"
          "max-buffer-size"       = "1m"
        }
      }

      linuxParameters = {
        initProcessEnabled = true
      }

      stopTimeout = 30
    }
  ])

  lifecycle {
    precondition {
      condition = length(setintersection(
        toset(keys(var.environment)),
        toset(keys(var.secret_parameter_arns))
      )) == 0

      error_message = "A variable cannot appear in both environment and secret_parameter_arns."
    }
  }

  depends_on = [
    aws_iam_role_policy.execution
  ]

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-api"
  })
}
