module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name               = "${var.env}-${var.cluster_name}"
  kubernetes_version = var.kubernetes_version

  vpc_id     = var.vpc_id
  subnet_ids = var.subnet_ids

  endpoint_public_access       = var.endpoint_public_access
  endpoint_public_access_cidrs = var.endpoint_public_access_cidrs

  enable_irsa                              = true
  enable_cluster_creator_admin_permissions = true
  authentication_mode                      = "API_AND_CONFIG_MAP"

  create_kms_key           = true
  attach_encryption_policy = true
  enable_kms_key_rotation  = true
  encryption_config = {
    resources = ["secrets"]
  }

  node_security_group_tags = {
    "karpenter.sh/discovery" = "${var.env}-${var.cluster_name}"
  }

  create_cloudwatch_log_group            = true
  cloudwatch_log_group_retention_in_days = var.cloudwatch_log_retention_days
  enabled_log_types                      = ["api", "audit", "authenticator"]

  addons = {
  coredns    = { most_recent = true }
  kube-proxy = { most_recent = true }

  vpc-cni = {
    most_recent    = true
    before_compute = true 
  }

  eks-pod-identity-agent = {
    most_recent    = true
    before_compute = true  # 
  }

  aws-ebs-csi-driver = {
    most_recent              = true
    service_account_role_arn = module.ebs_csi_irsa.iam_role_arn
  }
}

  eks_managed_node_groups = {
    default = {
      ami_type       = var.ami_type
      instance_types = var.node_instance_types
      capacity_type  = var.capacity_type
      min_size       = var.node_min_size
      max_size       = var.node_max_size
      desired_size   = var.node_desired_size
      disk_size      = var.node_disk_size
    }
  }

  tags = var.tags
}

module "ebs_csi_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.0"

  role_name             = "${var.env}-${var.cluster_name}-ebs-csi"
  attach_ebs_csi_policy = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
    }
  }

  tags = var.tags
}

module "karpenter" {
  source = "terraform-aws-modules/eks/aws//modules/karpenter"

  cluster_name = module.eks.cluster_name


  node_iam_role_additional_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }
}