module "dns" {
  source = "../route53"

  domain_root = var.domain_root
}