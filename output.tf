output "github_actions_role_arn" {
  value       = aws_iam_role.github_actions_role.arn
  description = "role ARN for GitHub Actions to assume when deploying with Terraform"
}

# print ALB url
output "alb_dns_name" {
  description = "The public URL of your Load Balancer"
  value       = aws_lb.app_alb.dns_name
}

# Triggering the infrastructure pipeline