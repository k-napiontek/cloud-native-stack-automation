include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${get_repo_root()}//01-terraform-infra/modules/route53"
}

locals {
  common_vars = read_terragrunt_config(find_in_parent_folders("_env.hcl"))
}

inputs = {
  domain_root = local.common_vars.locals.domain_root
}