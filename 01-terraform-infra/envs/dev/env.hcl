locals {
  env          = "dev"
  cluster_name = "main"
  domain       = "dev.bzyk0945.site"

  # --- Network ---
  vpc_cidr             = "10.0.0.0/16"
  private_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnet_cidrs  = ["10.0.101.0/24", "10.0.102.0/24"]
  single_nat_gateway   = true

  # --- EKS ---
  kubernetes_version   = "1.34"
  node_instance_types  = ["c7i-flex.large"]
  node_min_size        = 1
  node_max_size        = 3
  node_desired_size    = 2
  node_disk_size       = 20

  # --- RDS ---
  rds_instance_class              = "db.t3.micro"
  rds_allocated_storage           = 5
  rds_multi_az                    = false
  rds_backup_retention_period     = 1
  rds_monitoring_interval         = 0
  rds_performance_insights        = false
  rds_deletion_protection         = false
  rds_skip_final_snapshot         = true
  rds_apply_immediately           = true

  # --- Platform ---
  endpoint_public_access = true
}
