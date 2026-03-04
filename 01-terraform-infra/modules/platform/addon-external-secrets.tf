module "external_secrets_iam" {
  source          = "../addon-iam"
  env             = var.env
  addon_name      = "external-secrets"
  cluster_name    = var.cluster_name
  namespace       = "external-secrets"
  service_account = "external-secrets"
  policy_json = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["secretsmanager:GetSecretValue", "secretsmanager:DescribeSecret"]
      Resource = ["arn:aws:secretsmanager:eu-central-1:*:secret:${var.env}/*"]
    }]
  })
}