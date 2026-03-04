variable "env" {
  type = string
}

variable "identifier" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "allowed_cidr_blocks" {
  type    = list(string)
  default = []
}

variable "allowed_security_group_ids" {
  type    = list(string)
  default = []
}

variable "engine" {
  type    = string
  default = "postgres"
}

variable "engine_version" {
  type    = string
  default = "16"
}

variable "instance_class" {
  type    = string
  default = "db.t3.micro"
}

variable "allocated_storage" {
  type    = number
  default = 20
}

variable "db_name" {
  type = string
}

variable "username" {
  type    = string
  default = "dbadmin"
}

variable "port" {
  type    = number
  default = 5432
}

variable "multi_az" {
  type    = bool
  default = false
}

variable "maintenance_window" {
  type    = string
  default = "Mon:00:00-Mon:03:00"
}

variable "backup_window" {
  type    = string
  default = "03:00-06:00"
}

variable "backup_retention_period" {
  type    = number
  default = 7
}

variable "monitoring_interval" {
  type    = number
  default = 0
}

variable "performance_insights_enabled" {
  type    = bool
  default = false
}

variable "family" {
  type    = string
  default = "postgres16"
}

variable "major_engine_version" {
  type    = string
  default = "16"
}

variable "deletion_protection" {
  type    = bool
  default = true
}

variable "skip_final_snapshot" {
  type    = bool
  default = false
}

variable "apply_immediately" {
  type    = bool
  default = false
}

variable "parameters" {
  type    = list(any)
  default = []
}

variable "options" {
  type    = list(any)
  default = []
}

variable "tags" {
  type    = map(string)
  default = {}
}
