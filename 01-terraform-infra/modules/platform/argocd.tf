resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  create_namespace = true
  version          = "9.4.4"

  values = [file(var.argocd_values_path)]

  depends_on = [module.dns]
}

resource "kubectl_manifest" "root_infra" {
  yaml_body  = file(var.root_infra_yaml_path)
  depends_on = [helm_release.argocd]
}

resource "kubectl_manifest" "root_apps" {
  yaml_body  = file(var.root_apps_yaml_path)
  depends_on = [helm_release.argocd, kubectl_manifest.root_infra]
}

resource "kubectl_manifest" "root_issuers" {
  yaml_body  = file(var.root_issuers_yaml_path)
  depends_on = [helm_release.argocd]
}

resource "kubectl_manifest" "root_external_secrets" {
  yaml_body  = file(var.root_external_secrets_yaml_path)
  depends_on = [helm_release.argocd]
}