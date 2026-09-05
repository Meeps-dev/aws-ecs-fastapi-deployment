ephemeral "random_password" "application_secret_key" {
  length = 64

  upper   = true
  lower   = true
  numeric = true
  special = true

  min_upper   = 6
  min_lower   = 6
  min_numeric = 6
  min_special = 6

  override_special = "!#$%&*()-_=+[]{}<>:?"
}


resource "aws_ssm_parameter" "application_secret_key" {
  name        = "${local.ssm_parameter_prefix}/application/secret-key"
  description = "FastAPI JWT and application signing secret"

  type = "SecureString"
  tier = "Standard"

  value_wo         = ephemeral.random_password.application_secret_key.result
  value_wo_version = var.application_secret_version

  tags = merge(
    local.common_tags,
    {
      Name    = "${local.name_prefix}-application-secret-key"
      Purpose = "ecs-secret-injection"
    }
  )
}


