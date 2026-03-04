include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${get_repo_root()}//01-terraform-infra/modules/eks"
}

dependency "network" {
  config_path = "../network"

  mock_outputs_allowed_terraform_commands = ["validate", "plan", "init"]
  mock_outputs = {
    vpc_id          = "vpc-mock"
    private_subnets = ["subnet-mock-1", "subnet-mock-2"]
  }
}

locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
}

inputs = {
  env                  = local.env_vars.locals.env
  cluster_name         = local.env_vars.locals.cluster_name
  kubernetes_version   = local.env_vars.locals.kubernetes_version
  vpc_id               = dependency.network.outputs.vpc_id
  subnet_ids           = dependency.network.outputs.private_subnets
  endpoint_public_access = local.env_vars.locals.endpoint_public_access
  node_instance_types  = local.env_vars.locals.node_instance_types
  node_min_size        = local.env_vars.locals.node_min_size
  node_max_size        = local.env_vars.locals.node_max_size
  node_desired_size    = local.env_vars.locals.node_desired_size
  node_disk_size       = local.env_vars.locals.node_disk_size
}
