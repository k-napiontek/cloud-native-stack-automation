include "root" {
  path = find_in_parent_folders("root.hcl")
  expose = true
}

terraform {
  source = "${include.root.locals.base_module_url}/ecr?ref=infra-ecr-v1.1.0"
}

inputs = {
  repositories = {
    "myapp/catalog-service" = {}
    "myapp/inventory-service" = {}
    "myapp/storefront-bff"   = {}
    "myapp/storefront-web"   = {}
  }

  pull_account_arns = [
    "arn:aws:iam::188494185951:root",
  ]

  github_repo                 = "k-napiontek/cloud-native-stack-automation" // TODO: change to the correct repository
  create_github_oidc_provider = true
}
