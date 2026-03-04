include "root" {
  path = find_in_parent_folders("root.hcl")
  expose = true
}

terraform {
  source = "${include.root.locals.base_module_url}/vpc?ref=infra-vpc-v1.1.0"
}

locals {
  env_vars    = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  common_vars = read_terragrunt_config(find_in_parent_folders("_env.hcl"))
}

inputs = {
  env                  = local.env_vars.locals.env
  cluster_name         = local.env_vars.locals.cluster_name
  vpc_cidr             = local.env_vars.locals.vpc_cidr
  azs                  = local.common_vars.locals.azs
  private_subnet_cidrs = local.env_vars.locals.private_subnet_cidrs
  public_subnet_cidrs  = local.env_vars.locals.public_subnet_cidrs
  single_nat_gateway   = local.env_vars.locals.single_nat_gateway
}
