module "alb_controller_iam" {
  source          = "../addon-iam"
  env             = var.env
  addon_name      = "alb-controller"
  cluster_name    = var.cluster_name
  namespace       = "kube-system"
  service_account = "aws-load-balancer-controller"
  policy_json     = file("${path.module}/policies/alb-controller-policy.json")
}