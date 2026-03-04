resource "aws_security_group" "rds" {
  name_prefix = "${var.env}-${var.identifier}-rds-"
  description = "Security group for RDS ${var.identifier}"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = var.port
    to_port         = var.port
    protocol        = "tcp"
    cidr_blocks     = var.allowed_cidr_blocks
    security_groups = var.allowed_security_group_ids
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags

  lifecycle {
    create_before_destroy = true
  }
}

module "db" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 7.0"

  identifier = "${var.env}-${var.identifier}"

  engine            = var.engine
  engine_version    = var.engine_version
  instance_class    = var.instance_class
  allocated_storage = var.allocated_storage

  db_name  = var.db_name
  username = var.username
  port     = var.port

  manage_master_user_password = true

  iam_database_authentication_enabled = true

  vpc_security_group_ids = [aws_security_group.rds.id]

  multi_az             = var.multi_az
  db_subnet_group_name = module.db_subnet_group.db_subnet_group_id
  maintenance_window      = var.maintenance_window
  backup_window           = var.backup_window
  backup_retention_period = var.backup_retention_period

  monitoring_interval    = var.monitoring_interval
  monitoring_role_name   = "${var.env}-${var.identifier}-rds-monitoring"
  create_monitoring_role = var.monitoring_interval > 0

  storage_encrypted = true

  performance_insights_enabled = var.performance_insights_enabled

  family               = var.family
  major_engine_version = var.major_engine_version

  deletion_protection = var.deletion_protection
  skip_final_snapshot = var.skip_final_snapshot

  apply_immediately = var.apply_immediately

  parameters = var.parameters
  options    = var.options

  tags = var.tags
}

module "db_subnet_group" {
  source  = "terraform-aws-modules/rds/aws//modules/db_subnet_group"
  version = "~> 7.0"

  name       = "${var.env}-${var.identifier}"
  subnet_ids = var.subnet_ids

  tags = var.tags
}
