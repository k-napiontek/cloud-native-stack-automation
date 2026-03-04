locals {
  env          = "prod"
  cluster_name = "main"
  domain       = "bzyk0945.site"

  # --- Network ---
  vpc_cidr             = "10.2.0.0/16"
  private_subnet_cidrs = ["10.2.1.0/24", "10.2.2.0/24"]
  public_subnet_cidrs  = ["10.2.101.0/24", "10.2.102.0/24"]
  single_nat_gateway   = false

  # --- EKS ---
  kubernetes_version   = "1.32"
  node_instance_types  = ["r6g.large"]
  node_min_size        = 3
  node_max_size        = 10
  node_desired_size    = 3
  node_disk_size       = 50

  # --- RDS ---
  rds_instance_class              = "db.r6g.large"
  rds_allocated_storage           = 100
  rds_multi_az                    = true
  rds_backup_retention_period     = 30
  rds_monitoring_interval         = 30
  rds_performance_insights        = true
  rds_deletion_protection         = true
  rds_skip_final_snapshot         = false
  rds_apply_immediately           = false

  # --- Platform ---
  endpoint_public_access = false
}
