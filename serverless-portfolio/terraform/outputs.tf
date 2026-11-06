output "site_url" {
  description = "ポートフォリオの公開 URL"
  value       = "https://${aws_cloudfront_distribution.this.domain_name}"
}

output "s3_bucket" {
  value = aws_s3_bucket.site.id
}

output "cloudfront_distribution_id" {
  value = aws_cloudfront_distribution.this.id
}

output "github_actions_role_arn" {
  description = "GitHub Secrets の AWS_ROLE_ARN に設定する値"
  value       = aws_iam_role.github_actions.arn
}
