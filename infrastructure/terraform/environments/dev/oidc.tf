resource "aws_iam_role" "github_deploy" {
  name        = "${local.name_prefix}-github-deploy"
  description = "Repository-scoped GitHub Actions deployment role for Week 13"

  assume_role_policy   = data.aws_iam_policy_document.github_actions_assume_role.json
  max_session_duration = 3600

  tags = {
    Name = "${local.name_prefix}-github-deploy"
  }
}
