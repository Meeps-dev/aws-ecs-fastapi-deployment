resource "aws_iam_role" "github_plan" {
  name        = "${local.name_prefix}-github-plan"
  description = "Main-branch GitHub Actions role for Terraform planning only"

  assume_role_policy   = data.aws_iam_policy_document.github_actions_assume_role.json
  max_session_duration = 3600

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-github-plan"
    }
  )
}

resource "aws_iam_role_policy" "github_plan" {
  name   = "terraform-plan-readonly"
  role   = aws_iam_role.github_plan.id
  policy = data.aws_iam_policy_document.github_plan_permissions.json
}


resource "aws_iam_role" "github_deploy" {
  name        = "${local.name_prefix}-github-deploy"
  description = "Repository-scoped GitHub Actions deployment role for Week 13"

  assume_role_policy   = data.aws_iam_policy_document.github_actions_assume_role.json
  max_session_duration = 3600

  tags = {
    Name = "${local.name_prefix}-github-deploy"
  }
}


resource "aws_iam_role_policy" "github_deploy" {
  name   = "ecs-image-deployment"
  role   = aws_iam_role.github_deploy.id
  policy = data.aws_iam_policy_document.github_deploy_permissions.json
}
