locals {
  name_prefix = "${var.project_name}-${var.environment}"

  alb_name              = "meeps-${var.environment}-alb"
  alb_target_group_name = "meeps-${var.environment}-api-tg"
  ecs_service_name      = "${local.name_prefix}-api-service"

  github_oidc_subject = format(
    "repo:%s@%s/%s@%s:ref:refs/heads/%s",
    var.github_owner,
    var.github_owner_id,
    var.github_repository,
    var.github_repository_id,
    var.github_branch
  )

  ssm_parameter_prefix = "/meeps/week-13/${var.environment}/${var.project_name}"

  terraform_state_bucket   = "meeps-terraform-state-${var.aws_account_id}-${var.aws_region}"
  terraform_state_key      = "aws-ecs-fastapi-deployment/week-13/dev/terraform.tfstate"
  terraform_state_lock_key = "${local.terraform_state_key}.tflock"


  common_tags = {
    project      = "meeps"
    workload     = var.project_name
    week         = "week-13"
    environment  = var.environment
    owner        = var.owner
    "managed-by" = "terraform"
    repository   = var.github_repository
  }
}
