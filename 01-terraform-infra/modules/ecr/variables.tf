variable "repositories" {
  type        = map(any)
  description = "Map of ECR repository names to their config (e.g. read_write_arns)"
}

variable "pull_account_arns" {
  type        = list(string)
  default     = []
  description = "Account root ARNs that can pull images (cross-account)"
}

variable "github_repo" {
  type        = string
  default     = null
  description = "GitHub repository in format owner/repo for OIDC push access"
}

variable "create_github_oidc_provider" {
  type    = bool
  default = true
}

variable "github_oidc_provider_arn" {
  type        = string
  default     = null
  description = "Existing GitHub OIDC provider ARN (skip creation if set)"
}

variable "tags" {
  type    = map(string)
  default = {}
}
