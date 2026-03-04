include "root" {
  path = find_in_parent_folders("root.hcl")
  expose = true
}

terraform {
  source = "${include.root.locals.base_module_url}/rds?ref=infra-rds-v1.1.0"
}

dependency "network" {
  config_path = "../network"

  mock_outputs_allowed_terraform_commands = ["validate", "plan", "init"]
  mock_outputs = {
    vpc_id          = "vpc-mock"
    vpc_cidr_block  = "10.1.0.0/16"
    private_subnets = ["subnet-mock-1", "subnet-mock-2"]
  }
}

locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
}

inputs = {
  env        = local.env_vars.locals.env
  identifier = "myapp"
  db_name    = "myapp"

  vpc_id     = dependency.network.outputs.vpc_id
  subnet_ids = dependency.network.outputs.private_subnets

  allowed_cidr_blocks = [dependency.network.outputs.vpc_cidr_block]

  instance_class              = local.env_vars.locals.rds_instance_class
  allocated_storage           = local.env_vars.locals.rds_allocated_storage
  multi_az                    = local.env_vars.locals.rds_multi_az
  deletion_protection         = local.env_vars.locals.rds_deletion_protection
  skip_final_snapshot         = local.env_vars.locals.rds_skip_final_snapshot
  apply_immediately           = local.env_vars.locals.rds_apply_immediately
  backup_retention_period     = local.env_vars.locals.rds_backup_retention_period
  monitoring_interval         = local.env_vars.locals.rds_monitoring_interval
  performance_insights_enabled = local.env_vars.locals.rds_performance_insights
}
