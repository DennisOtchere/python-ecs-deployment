resource "aws_ecr_repository" "welcome-app-repo" {
  name                 = "welcome-app-repo"
  image_tag_mutability = "MUTABLE"
}