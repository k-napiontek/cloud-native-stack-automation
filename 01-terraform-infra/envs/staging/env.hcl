locals {
  env          = "stg"
  cluster_name = "main"
  domain       = "stg.bzyk0945.site"

  # --- Network ---
  vpc_cidr             = "10.1.0.0/16"
  private_subnet_cidrs = ["10.1.1.0/24", "10.1.2.0/24"]
  public_subnet_cidrs  = ["10.1.101.0/24", "10.1.102.0/24"]
  single_nat_gateway   = true

  # --- EKS ---
  kubernetes_version   = "1.32"
  node_instance_types  = ["t3.medium"]
  node_min_size        = 2
  node_max_size        = 6
  node_desired_size    = 2
  node_disk_size       = 30

  # --- RDS ---
  rds_instance_class              = "db.t3.small"
  rds_allocated_storage           = 20
  rds_multi_az                    = false
  rds_backup_retention_period     = 7
  rds_monitoring_interval         = 60
  rds_performance_insights        = true
  rds_deletion_protection         = true
  rds_skip_final_snapshot         = false
  rds_apply_immediately           = false

  # --- Platform ---
  endpoint_public_access = true
}
