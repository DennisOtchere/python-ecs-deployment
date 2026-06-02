terraform {
  backend "s3" {
    bucket       = "python-app-terraform-state-vault-2026"
    key          = "global/s3/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}