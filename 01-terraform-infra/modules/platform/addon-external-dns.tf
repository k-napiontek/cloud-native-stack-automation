module "external_dns_iam" {
  source          = "../addon-iam"
  env             = var.env
  addon_name      = "external-dns"
  cluster_name    = var.cluster_name
  namespace       = "kube-system"
  service_account = "external-dns-sa"
  policy_json = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["route53:ChangeResourceRecordSets"]
        Resource = ["arn:aws:route53:::hostedzone/${module.dns.zone_id}"]
      },
      {
        Effect   = "Allow"
        Action   = ["route53:ListHostedZones", "route53:ListResourceRecordSets"]
        Resource = ["*"]
      }
    ]
  })
}