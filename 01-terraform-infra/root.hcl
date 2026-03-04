locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  env_vars     = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  common_vars  = read_terragrunt_config(find_in_parent_folders("_env.hcl"))

  env        = local.env_vars.locals.env
  project    = local.common_vars.locals.project
  account_id = local.account_vars.locals.account_id
  layer      = basename(get_terragrunt_dir())

  base_module_url = "git::https://github.com/k-napiontek/cloud-native-stack-automation.git//01-terraform-infra/modules" # TODO: CHANGE TO YOUR OWN REPO
}

terraform_binary = "tofu"

generate "backend" {
  path      = "backend_generated.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<-EOF
    terraform {
      required_version = ">= 1.11.0"

      backend "s3" {
        bucket       = "tfstate-${local.account_id}" 
        key          = "${local.env}/${local.layer}/terraform.tfstate"
        region       = "eu-central-1"
        encrypt      = true
        use_lockfile = true

        assume_role = {
          role_arn = "${local.account_vars.locals.role_arn}"
        }
      }
    }
  EOF
}

generate "provider" {
  path      = "provider_generated.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<-EOF
    provider "aws" {
      region = "eu-central-1"

      assume_role {
        role_arn = "${local.account_vars.locals.role_arn}"
      }

      default_tags {
        tags = {
          Environment = "${local.env}"
          Terraform   = "true"
          Project     = "${local.project}"
        }
      }
    }
  EOF
}


