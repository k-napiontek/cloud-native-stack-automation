module "ecr" {
  source  = "terraform-aws-modules/ecr/aws"
  version = "~> 3.0"

  for_each = var.repositories

  repository_name                   = each.key
  repository_image_scan_on_push     = true
  repository_read_write_access_arns = try(each.value.read_write_arns, [])
  repository_read_access_arns       = var.pull_account_arns

  repository_lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 30 tagged images"
        selection = {
          tagStatus     = "tagged"
          tagPrefixList = ["v"]
          countType     = "imageCountMoreThan"
          countNumber   = 30
        }
        action = { type = "expire" }
      },
      {
        rulePriority = 2
        description  = "Remove untagged after 7 days"
        selection = {
          tagStatus   = "untagged"
          countType   = "sinceImagePushed"
          countUnit   = "days"
          countNumber = 7
        }
        action = { type = "expire" }
      }
    ]
  })

  tags = var.tags
}


resource "aws_iam_openid_connect_provider" "github" {
  count = var.create_github_oidc_provider ? 1 : 0

  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]

  tags = var.tags
}

locals {
  oidc_provider_arn = var.create_github_oidc_provider ? aws_iam_openid_connect_provider.github[0].arn : var.github_oidc_provider_arn
  create_gh_roles   = var.github_repo != null
}

resource "aws_iam_policy" "ecr_push" {
  for_each = local.create_gh_roles ? var.repositories : {}

  name = "${replace(each.key, "/", "-")}-github-ecr-push"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["ecr:GetAuthorizationToken"]
        Resource = ["*"]
      },
      {
        Effect = "Allow"
        Action = [
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability",
          "ecr:CompleteLayerUpload",
          "ecr:GetDownloadUrlForLayer",
          "ecr:InitiateLayerUpload",
          "ecr:PutImage",
          "ecr:UploadLayerPart"
        ]
        Resource = [module.ecr[each.key].repository_arn]
      }
    ]
  })

  tags = var.tags
}

module "github_actions_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-github-oidc-role"
  version = "~> 5.0"

  for_each = local.create_gh_roles ? var.repositories : {}

  name     = "${replace(each.key, "/", "-")}-github-actions"
  subjects = ["repo:${var.github_repo}:ref:refs/heads/*"]

  policies = {
    ECRPush = aws_iam_policy.ecr_push[each.key].arn
  }

  tags = var.tags
}
