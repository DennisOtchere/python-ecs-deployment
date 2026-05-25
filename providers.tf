/*
 This providers.tf configures the AWS provider for deploying resources such as
 an ECS cluster, task definitions, and related networking/services used to
 deploy a Python Flask app to Amazon ECS.
*/

terraform {
	required_version = ">= 1.0.0"

	required_providers {
		aws = {
			source  = "hashicorp/aws"
			version = "~> 6.0"
		}
	}
}

provider "aws" {
	region = var.aws_region
    default_tags {
      tags = {
      environment = "dev"
      owner       = "engineer"
      managed-by  = "terraform"
    }

    }
}


