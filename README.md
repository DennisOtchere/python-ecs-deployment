# welcome-app — Setup & Deployment

This repository contains a small Flask application and Terraform configuration to provision AWS resources (VPC, subnet, security group, ECR repo, ECS cluster and task definition). The README below describes step-by-step local development, container build, and infrastructure provisioning workflows.

**Quick links**

- Source code: [app.py](app.py)
- Dockerfile: [Dockerfile](Dockerfile)
- Terraform files: [providers.tf](providers.tf), [variables.tf](variables.tf), [network.tf](network.tf), [ecr.tf](ecr.tf), [ecs.tf](ecs.tf), [iam.tf](iam.tf)

## Prerequisites

- macOS, Linux, or Windows Subsystem for Linux
- Installations:
  - `git`
  - `python3.11` (or `python3`) and `venv`
  - `docker` (for building/pushing images)
  - `awscli` (v2 recommended)
  - `terraform` (v1.0+)

- AWS credentials configured (one of):
  - Run `aws configure` and provide `AWS Access Key`, `Secret`, and `region`.
  - Or set environment variables `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_REGION` / `AWS_DEFAULT_REGION`.

## Local development (Python)

1. Create and activate a virtual environment:

```bash
python3 -m venv venv
source venv/bin/activate
```

2. Install dependencies:

```bash
pip install -r requirements.txt
```

3. Run the app locally:

```bash
python app.py
# or with gunicorn (production-like):
gunicorn -b 0.0.0.0:3000 app:app
```

Visit http://localhost:3000/ to confirm the app is running.

## Build and run with Docker

1. Build the image locally:

```bash
docker build -t welcome-app:local .
```

2. Run the container:

```bash
docker run --rm -p 3000:3000 welcome-app:local
```

3. Test:

```bash
curl http://localhost:3000/
curl http://localhost:3000/yourname
```

## Provision AWS infrastructure with Terraform

The Terraform files in the repo create a VPC, subnet, security group, an ECR repository `welcome-app-repo`, an ECS cluster, a task definition, and an IAM role for ECS task execution.

1. Initialize Terraform (from repo root):

```bash
cd /path/to/welcome-app
terraform init
```

2. (Optional) Review plan:

```bash
terraform plan -out plan.tfplan
```

3. Apply the plan (creates resources):

```bash
terraform apply "plan.tfplan"
# or directly:
terraform apply -auto-approve
```

Notes:

- The AWS region used is controlled by `var.aws_region` (default: `us-east-1`) defined in `variables.tf`. Override with `-var="aws_region=eu-west-1"` when running `terraform` commands.

## Build, tag, and push image to ECR

After `terraform apply` the ECR repository resource exists. Use the following to push a built image to ECR so ECS can pull it.

1. Get AWS account ID and region in shell:

```bash
export AWS_REGION=${AWS_REGION:-us-east-1}
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
```

2. Discover repository URI created by Terraform:

```bash
REPO_URI=$(aws ecr describe-repositories --repository-names welcome-app-repo --query 'repositories[0].repositoryUri' --output text)
echo "$REPO_URI"
```

3. Authenticate Docker to ECR and push:

```bash
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin ${ACCOUNT_ID}.dkr.ecr.$AWS_REGION.amazonaws.com
docker build -t welcome-app:latest .
docker tag welcome-app:latest $REPO_URI:latest
docker push $REPO_URI:latest
```

Important: The task definition in `ecs.tf` references `${aws_ecr_repository.welcome-app-repo.repository_url}:latest`. Ensure the `:latest` image exists in ECR before creating/running ECS tasks to avoid pull/runtime errors.

## Notes about ECS deployment

- The repo includes an ECS cluster and task definition, and it also contains `iam.tf` for an ECS task execution role. However, the current ECS task definition does not yet reference that role directly, so the deployment is not fully wired for production.
  - Create an ECS service via the AWS Console, specifying the task definition `python-app-task` and the VPC/subnet/security group created by Terraform.
  - Or extend the Terraform code to create `aws_ecs_service`, set `execution_role_arn` on the task definition, and add any additional IAM roles or policies required for your workload.

## Useful commands

- Destroy all Terraform-managed resources:

```bash
terraform destroy -auto-approve
```

- Show details for the created ECR repo:

```bash
aws ecr describe-repositories --repository-names welcome-app-repo
```

## Updating this guide

This README is intended to be the canonical setup guide. When new files or configuration are added (for example: outputs, additional Terraform modules, CI/CD pipelines), update this document with the new steps and any required new environment variables or commands.

---

### Shortcut: AWS free-tier instance types

```bash
aws ec2 describe-instance-types --filters "Name=free-tier-eligible,Values=true" --query "InstanceTypes[*].InstanceType" --output table
```
