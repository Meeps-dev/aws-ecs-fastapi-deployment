resource "aws_ecs_service" "api" {
  name = local.ecs_service_name

  cluster         = module.ecs.cluster_arn
  task_definition = module.ecs.task_definition_arn

  desired_count       = 1
  launch_type         = "FARGATE"
  platform_version    = "1.4.0"
  scheduling_strategy = "REPLICA"

  deployment_controller {
    type = "ECS"
  }

  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent         = 200
  health_check_grace_period_seconds  = 60

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  network_configuration {
    subnets = module.vpc.public_subnet_ids

    security_groups = [
      module.security.ecs_security_group_id
    ]

    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = module.alb.target_group_arn
    container_name   = module.ecs.container_name
    container_port   = var.application_port
  }

  enable_ecs_managed_tags = true
  enable_execute_command  = false
  propagate_tags          = "SERVICE"

  wait_for_steady_state = true

  depends_on = [
    module.alb
  ]

  tags = merge(
    local.common_tags,
    {
      Name = local.ecs_service_name
    }
  )

  timeouts {
    create = "30m"
    update = "30m"
    delete = "20m"
  }
}
