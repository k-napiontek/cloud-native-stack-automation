include "root" {
  path = find_in_parent_folders("root.hcl")
  expose = true
}

terraform {
  source = "${include.root.locals.base_module_url}/platform?ref=infra-platform-v1.1.0"
}

dependency "compute" {
  config_path = "../compute"

  mock_outputs_allowed_terraform_commands = ["validate", "plan", "init"]
  mock_outputs = {
    cluster_name                       = "mock-cluster"
    cluster_endpoint                   = "https://mock.eks.amazonaws.com"
    cluster_certificate_authority_data = "LS0tLS1CRUdJTi..."
  }
}

locals {
  env_vars    = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  common_vars = read_terragrunt_config(find_in_parent_folders("_env.hcl"))
}

generate "k8s_providers" {
  path      = "k8s_providers_generated.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<-EOF
    data "aws_eks_cluster_auth" "this" {
      name = "${dependency.compute.outputs.cluster_name}"
    }

    provider "helm" {
      kubernetes {
        host                   = "${dependency.compute.outputs.cluster_endpoint}"
        cluster_ca_certificate = base64decode("${dependency.compute.outputs.cluster_certificate_authority_data}")
        token                  = data.aws_eks_cluster_auth.this.token
      }
    }

    provider "kubectl" {
      host                   = "${dependency.compute.outputs.cluster_endpoint}"
      cluster_ca_certificate = base64decode("${dependency.compute.outputs.cluster_certificate_authority_data}")
      token                  = data.aws_eks_cluster_auth.this.token
      load_config_file       = false
    }
  EOF
}

inputs = {
  env          = local.env_vars.locals.env
  cluster_name = dependency.compute.outputs.cluster_name
  domain_root  = local.common_vars.locals.domain_root

  argocd_values_path   = "${get_terragrunt_dir()}/argocd-values.yaml"
  root_infra_yaml_path = "${get_repo_root()}/03-gitops-infra/root-infra.yaml"
  root_apps_yaml_path  = "${get_repo_root()}/04-gitops-apps/prod-appset.yaml"
}
