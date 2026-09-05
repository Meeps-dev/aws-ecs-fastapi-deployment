resource "aws_lb" "this" {
  name               = var.load_balancer_name
  internal           = false
  load_balancer_type = "application"

  security_groups = [
    var.alb_security_group_id
  ]

  subnets = var.public_subnet_ids

  ip_address_type            = "ipv4"
  enable_deletion_protection = false
  drop_invalid_header_fields = true

  tags = merge(
    var.tags,
    {
      Name = var.load_balancer_name
    }
  )
}

resource "aws_lb_target_group" "api" {
  name = var.target_group_name

  vpc_id      = var.vpc_id
  target_type = "ip"

  protocol         = "HTTP"
  protocol_version = "HTTP1"
  port             = var.application_port

  deregistration_delay = 30

  health_check {
    enabled = true

    protocol = "HTTP"
    port     = "traffic-port"
    path     = var.health_check_path
    matcher  = "200"

    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = merge(
    var.tags,
    {
      Name = var.target_group_name
    }
  )
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn

  port     = 80
  protocol = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.api.arn
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.load_balancer_name}-http"
    }
  )
}
