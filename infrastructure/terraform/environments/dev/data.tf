data "aws_caller_identity" "current" {}

data "aws_partition" "current" {}

data "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"
}

data "aws_iam_policy_document" "github_actions_assume_role" {
  statement {
    sid    = "GitHubActionsAssumeRole"
    effect = "Allow"

    actions = [
      "sts:AssumeRoleWithWebIdentity"
    ]

    principals {
      type = "Federated"

      identifiers = [
        data.aws_iam_openid_connect_provider.github.arn
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"

      values = [
        "sts.amazonaws.com"
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"

      values = [
        local.github_oidc_subject
      ]
    }
  }
}


data "aws_iam_policy_document" "github_plan_permissions" {
  statement {
    sid    = "ReadTerraformStateBucket"
    effect = "Allow"

    actions = [
      "s3:GetBucketLocation",
      "s3:ListBucket"
    ]

    resources = [
      "arn:${data.aws_partition.current.partition}:s3:::${local.terraform_state_bucket}"
    ]

    condition {
      test     = "StringLike"
      variable = "s3:prefix"

      values = [
        local.terraform_state_key,
        local.terraform_state_lock_key
      ]
    }
  }

  statement {
    sid    = "ReadTerraformState"
    effect = "Allow"

    actions = [
      "s3:GetObject"
    ]

    resources = [
      "arn:${data.aws_partition.current.partition}:s3:::${local.terraform_state_bucket}/${local.terraform_state_key}"
    ]
  }

  statement {
    sid    = "ManageTerraformStateLock"
    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject"
    ]

    resources = [
      "arn:${data.aws_partition.current.partition}:s3:::${local.terraform_state_bucket}/${local.terraform_state_lock_key}"
    ]
  }

  statement {
    sid    = "ReadInfrastructureMetadata"
    effect = "Allow"

    actions = [
      "ec2:Describe*",

      "ecr:DescribeImages",
      "ecr:DescribeRepositories",
      "ecr:GetLifecyclePolicy",
      "ecr:ListTagsForResource",

      "ecs:DescribeClusters",
      "ecs:DescribeServices",
      "ecs:DescribeTaskDefinition",
      "ecs:ListTagsForResource",

      "elasticloadbalancing:Describe*",

      "iam:GetOpenIDConnectProvider",
      "iam:GetRole",
      "iam:GetRolePolicy",
      "iam:ListAttachedRolePolicies",
      "iam:ListOpenIDConnectProviders",
      "iam:ListRolePolicies",
      "iam:ListRoleTags",

      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
      "logs:ListTagsForResource",

      "rds:DescribeDBEngineVersions",
      "rds:DescribeDBInstances",
      "rds:DescribeDBSubnetGroups",
      "rds:ListTagsForResource",

      "sts:GetCallerIdentity",
      "tag:GetResources"
    ]

    resources = ["*"]
  }

  statement {
    sid    = "ReadRequiredTerraformParameters"
    effect = "Allow"

    actions = [
      "ssm:GetParameter",
      "ssm:GetParameters",
      "ssm:ListTagsForResource"
    ]

    resources = [
      module.rds.db_password_parameter_arn,
      module.rds.database_url_parameter_arn,
      aws_ssm_parameter.application_secret_key.arn
    ]
  }
}

data "aws_iam_policy_document" "github_deploy_permissions" {
  statement {
    sid    = "ReadTerraformStateBucket"
    effect = "Allow"

    actions = [
      "s3:GetBucketLocation",
      "s3:ListBucket"
    ]

    resources = [
      "arn:${data.aws_partition.current.partition}:s3:::${local.terraform_state_bucket}"
    ]

    condition {
      test     = "StringLike"
      variable = "s3:prefix"

      values = [
        local.terraform_state_key
      ]
    }
  }

  statement {
    sid    = "ReadTerraformState"
    effect = "Allow"

    actions = [
      "s3:GetObject"
    ]

    resources = [
      "arn:${data.aws_partition.current.partition}:s3:::${local.terraform_state_bucket}/${local.terraform_state_key}"
    ]
  }

  statement {
    sid     = "AuthenticateToECR"
    effect  = "Allow"
    actions = ["ecr:GetAuthorizationToken"]

    resources = ["*"]
  }

  statement {
    sid    = "PublishApplicationImage"
    effect = "Allow"

    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage",
      "ecr:CompleteLayerUpload",
      "ecr:DescribeImages",
      "ecr:GetDownloadUrlForLayer",
      "ecr:InitiateLayerUpload",
      "ecr:ListImages",
      "ecr:PutImage",
      "ecr:UploadLayerPart"
    ]

    resources = [
      module.ecr.repository_arn
    ]
  }

  statement {
    sid    = "RegisterTaskDefinition"
    effect = "Allow"

    actions = [
      "ecs:DescribeTaskDefinition",
      "ecs:RegisterTaskDefinition"
    ]

    resources = ["*"]
  }

  statement {
    sid    = "DeployApplicationService"
    effect = "Allow"

    actions = [
      "ecs:DescribeServices",
      "ecs:UpdateService"
    ]

    resources = [
      aws_ecs_service.api.id
    ]
  }

  statement {
    sid    = "InspectDeployment"
    effect = "Allow"

    actions = [
      "ecs:DescribeClusters",
      "ecs:DescribeTasks",
      "ecs:ListTasks",
      "elasticloadbalancing:DescribeTargetHealth"
    ]

    resources = ["*"]
  }

  statement {
    sid    = "PassExactECSTaskRoles"
    effect = "Allow"

    actions = [
      "iam:PassRole"
    ]

    resources = [
      module.ecs.execution_role_arn,
      module.ecs.task_role_arn
    ]

    condition {
      test     = "StringEquals"
      variable = "iam:PassedToService"

      values = [
        "ecs-tasks.amazonaws.com"
      ]
    }
  }
}
