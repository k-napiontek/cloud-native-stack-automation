output "repository_urls" {
  value       = { for k, v in module.ecr : k => v.repository_url }
  description = "Map of repository name to URL"
}

output "repository_arns" {
  value       = { for k, v in module.ecr : k => v.repository_arn }
  description = "Map of repository name to ARN"
}

output "github_role_arns" {
  value       = { for k, v in module.github_actions_role : k => v.arn }
  description = "Map of repository name to GitHub Actions IAM role ARN"
}
