include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${get_repo_root()}//01-terraform-infra/modules/platform"
}

dependency "dns" {
  config_path = "../dns"

  mock_outputs_allowed_terraform_commands = ["validate", "plan", "init", "destroy"]
  mock_outputs = {
    zone_id         = "Z00000000000000000000"
    certificate_arn = "arn:aws:acm:eu-central-1:000000000000:certificate/mock"
  }
}

dependency "compute" {
  config_path = "../compute"

  mock_outputs_allowed_terraform_commands = ["validate", "plan", "init", "destroy"]
  mock_outputs = {
    cluster_name                       = "mock-cluster"
    cluster_endpoint                   = "https://mock.eks.amazonaws.com"
    cluster_certificate_authority_data = "LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUJjekNDQVJtZ0F3SUJBZ0lVS1NPQ24wcTM5L0dYa2JmSE9vdTFTbDdYM0NJd0NnWUlLb1pJemowRUF3SXcKRHpFTk1Bc0dBMVVFQXd3RWJXOWphekFlRncweU5qQXlNall4TmpRNE5ERmFGdzB6TmpBeU1qUXhOalE0TkRGYQpNQTh4RFRBTEJnTlZCQU1NQkcxdlkyc3dXVEFUQmdjcWhrak9QUUlCQmdncWhrak9QUU1CQndOQ0FBUkpHYjN5CmR2d0RFMmpROEJrcDZtaGR4M25udnVoTENOMnFIQzlVYU9Fc3RIcGZySExyb1lUcitrMHNvVUZiUjNrQ1RrcVYKK05UWEd3ZDZtRzZlMnNXZW8xTXdVVEFkQmdOVkhRNEVGZ1FVT3gyRnRHNnZNaFRoYU5qWjdJMVV1eWZxVXVVdwpId1lEVlIwakJCZ3dGb0FVT3gyRnRHNnZNaFRoYU5qWjdJMVV1eWZxVXVVd0R3WURWUjBUQVFIL0JBVXdBd0VCCi96QUtCZ2dxaGtqT1BRUURBZ05JQURCRkFpQWVHZ3BwZ1Bpc2R4cnJzbFZLK2tsMkZEOEJYTCt0a0lTV1ptZUsKK0tEeEF3SWhBUCs0RmZqWDBscDJaKzE5NkpuaDhVZFg2STQ0TVh1ckFUamxCTEFzdFB2dwotLS0tLUVORCBDRVJUSUZJQ0FURS0tLS0tCg=="
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

  zone_id         = dependency.dns.outputs.zone_id
  certificate_arn = dependency.dns.outputs.certificate_arn

  argocd_values_path                = "${get_terragrunt_dir()}/argocd-values.yaml"
  root_apps_yaml_path               = "${get_repo_root()}/04-gitops-apps/appsets/dev.yaml"
  root_infra_yaml_path              = "${get_repo_root()}/03-gitops-infra/appsets/dev-infra.yaml"
  root_issuers_yaml_path            = "${get_repo_root()}/03-gitops-infra/appsets/dev-issuers.yaml"
  root_external_secrets_yaml_path   = "${get_repo_root()}/03-gitops-infra/appsets/dev-external-secrets.yaml"
}
