output "alb_controller_role_arn" {
  value = module.alb_controller_iam.role_arn
}

output "zone_id" {
  value = module.dns.zone_id
}

output "name_servers" {
  value = module.dns.name_servers
}

output "certificate_arn" {
  value = module.dns.certificate_arn
}

output "external_dns_role_arn" {
  value = module.external_dns_iam.role_arn
}

output "argocd_namespace" {
  value = helm_release.argocd.namespace
}