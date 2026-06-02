resource "aws_s3_bucket" "terraform_state" {
  bucket = "python-app-terraform-state-vault-2026"
}

resource "aws_s3_bucket_versioning" "terraform_state_versioning" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}
