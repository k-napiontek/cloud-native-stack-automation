resource "random_password" "grafana_admin" {
  length  = 24
  special = false
}

resource "aws_secretsmanager_secret" "grafana" {
  name = "${var.env}/grafana"
  tags = var.tags
}

resource "aws_secretsmanager_secret_version" "grafana" {
  secret_id     = aws_secretsmanager_secret.grafana.id
  secret_string = jsonencode({
    admin-user     = "admin"
    admin-password = random_password.grafana_admin.result
  })
  lifecycle { ignore_changes = [secret_string] }
}


resource "aws_secretsmanager_secret" "argocd_github_oauth" {
  name        = "${var.env}/argocd/github-oauth"
  description = "GitHub OAuth Client Secret dla ArgoCD"
}


resource "aws_secretsmanager_secret_version" "argocd_github_oauth_dummy" {
  secret_id     = aws_secretsmanager_secret.argocd_github_oauth.id
  secret_string = jsonencode({
    clientSecret = "TUTAJ_WKLEISZ_RECZNIE_SECRET_W_AWS"
  })
  
  lifecycle {
    ignore_changes = [secret_string] 
  }
}