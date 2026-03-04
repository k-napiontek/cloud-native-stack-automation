resource "aws_s3_bucket" "loki" {
  bucket = "${var.cluster_name}-loki-chunks"
  force_destroy = true # TODO: IN PROD DISABLE FORCE DESTROY
  tags   = var.tags
}

resource "aws_s3_bucket_lifecycle_configuration" "loki" {
  bucket = aws_s3_bucket.loki.id
  rule {
    id     = "expire-old-logs"
    status = "Enabled"
    expiration { days = var.env == "prod" ? 90 : 30 }
  }
}