output "github_actions_role_arn" {
  value       = aws_iam_role.github_actions_role.arn
  description = "role ARN for GitHub Actions to assume when deploying with Terraform"
}