module "loki_iam" {
  source          = "../addon-iam"
  env             = var.env
  addon_name      = "loki"
  cluster_name    = var.cluster_name
  namespace       = "monitoring"
  service_account = "loki"
  policy_json = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["s3:PutObject", "s3:GetObject", "s3:DeleteObject", "s3:ListBucket"]
      Resource = [aws_s3_bucket.loki.arn, "${aws_s3_bucket.loki.arn}/*"]
    }]
  })
}