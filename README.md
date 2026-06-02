# Welcome App — Python Flask Deployment on AWS ECS

A production-ready Python Flask application with Infrastructure-as-Code (Terraform) for automated AWS deployment. This project demonstrates containerization with Docker and infrastructure provisioning on Amazon ECS using VPC, ECR, and IAM best practices.

**Repository:** [DennisOtchere/python-ecs-deployment](https://github.com/DennisOtchere/python-ecs-deployment)

---

## 📋 Table of Contents

- [Overview](#overview)
- [Project Architecture](#project-architecture)
- [File Structure & Descriptions](#file-structure--descriptions)
- [Prerequisites](#prerequisites)
- [Getting Started](#getting-started)
- [Local Development](#local-development)
- [Docker Build & Run](#docker-build--run)
- [Infrastructure Deployment](#infrastructure-deployment)
- [CI/CD Pipeline](#cicd-pipeline)
- [Troubleshooting](#troubleshooting)

---

## 🎯 Overview

**Welcome App** is a lightweight Flask web application designed to run on Amazon ECS. It provides:

- ✅ **HTTP endpoints** for health checks and dynamic greetings
- 🐳 **Docker containerization** for consistent environments
- 🏗️ **Infrastructure-as-Code** using Terraform for AWS provisioning
- 🔐 **AWS security best practices** with VPC isolation and IAM roles
- 🤖 **CI/CD automation** via GitHub Actions with OIDC authentication
- 💾 **State management** with S3 backend for Terraform

**Use case:** Demonstration of deploying a Python microservice on AWS ECS with automated infrastructure provisioning and container orchestration.

---

## 🏗️ Project Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    GitHub Actions (OIDC)                    │
│                   Terraform CI/CD Pipeline                  │
└─────────────────┬───────────────────────────────────────────┘
                  │
                  ▼
         ┌────────────────┐
         │   AWS Account  │
         │                │
         │  ┌──────────┐  │
         │  │    VPC   │  │
         │  │          │  │
         │  │ ┌──────┐ │  │
         │  │ │  ALB │ │  │
         │  │ └──┬───┘ │  │
         │  │    │     │  │
         │  │    ▼     │  │
         │  │ ┌──────┐ │  │
         │  │ │ ECS  │ │  │
         │  │ │Tasks │ │  │
         │  │ └──────┘ │  │
         │  │          │  │
         │  └──────────┘  │
         │                │
         │  ┌──────────┐  │
         │  │   ECR    │  │
         │  │ Registry │  │
         │  └──────────┘  │
         │                │
         └────────────────┘
```

---

## 📁 File Structure & Descriptions

### Application Code

| File | Purpose |
|------|---------|
| **`app.py`** | Main Flask application with two endpoints:<br/>- `GET /` - Returns "Application Running" health check<br/>- `GET /<name>` - Returns personalized welcome message |
| **`requirements.txt`** | Python dependencies (Flask 3.0.0, Gunicorn 21.2.0) |

### Containerization

| File | Purpose |
|------|---------|
| **`Dockerfile`** | Multi-stage Docker image definition:<br/>- Base: Python 3.11-slim<br/>- Installs dependencies via pip<br/>- Exposes port 3000<br/>- Runs with Gunicorn WSGI server for production |
| **`.dockerignore`** | Excludes unnecessary files from Docker build context (reduces image size) |

### Infrastructure as Code (Terraform)

| File | Purpose |
|------|---------|
| **`providers.tf`** | Configures AWS provider, Terraform version (>= 1.0.0), required AWS provider version (~> 6.0) |
| **`variables.tf`** | Defines input variables (currently: `aws_region` with default `us-east-1`) |
| **`state.tf`** | Defines S3 backend for remote Terraform state management with versioning enabled |
| **`network.tf`** | Provisions networking infrastructure:<br/>- VPC (Virtual Private Cloud)<br/>- Public/private subnets<br/>- Internet Gateway<br/>- Route tables and security groups |
| **`ecr.tf`** | Creates ECR (Elastic Container Registry) repository (`welcome-app-repo`) for storing Docker images |
| **`ecs.tf`** | Defines ECS cluster, task definition (`python-app-task`), and container configuration:<br/>- CPU/memory allocation<br/>- Container image reference<br/>- Port mappings |
| **`iam.tf`** | Creates IAM roles and policies:<br/>- ECS task execution role<br/>- Permissions for ECR pull and CloudWatch logging |
| **`output.tf`** | Exports key infrastructure values (ECR URL, ECS cluster name, etc.) for reference |
| **`alb.tf`** | Configures Application Load Balancer (ALB):<br/>- Listener rules for traffic routing<br/>- Target group configuration |
| **`backend.tf`** | Specifies remote S3 backend configuration for state storage (optional local config) |

### CI/CD Pipeline

| File | Purpose |
|------|---------|
| **`terraform.yml`** | GitHub Actions workflow:<br/>- Triggers on push to `main` when `.tf` files change<br/>- Uses AWS OIDC for keyless authentication<br/>- Runs: Terraform init → format check → plan → apply |

---

## 🚀 Prerequisites

### System Requirements
- **OS:** macOS, Linux, or Windows Subsystem for Linux (WSL)
- **Git:** For version control

### Development Tools
- **Python 3.11+** — Application runtime and virtual environment support
- **Docker** — For building and testing container images
- **Terraform v1.0+** — Infrastructure provisioning
- **AWS CLI v2** — AWS resource management and authentication

### AWS Account & Credentials
AWS credentials configured via one of these methods:

**Option 1: AWS CLI Configuration**
```bash
aws configure
# Provide: Access Key ID, Secret Access Key, Region, Output format
```

**Option 2: Environment Variables**
```bash
export AWS_ACCESS_KEY_ID=your_access_key
export AWS_SECRET_ACCESS_KEY=your_secret_key
export AWS_REGION=us-east-1
```

**Option 3: GitHub Actions OIDC (for CI/CD)**
- IAM role with trust relationship to GitHub Actions
- Set in GitHub repository secrets or GitHub organization settings

---

## 🏁 Getting Started

### 1. Clone the Repository
```bash
git clone https://github.com/DennisOtchere/python-ecs-deployment.git
cd python-ecs-deployment
```

### 2. Verify Prerequisites
```bash
# Check Python version
python3 --version  # Should be 3.11 or higher

# Check other tools
docker --version
terraform --version
aws --version

# Verify AWS credentials
aws sts get-caller-identity
```

### 3. Quick Start (Local Development)
```bash
# Create virtual environment
python3 -m venv venv
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Run locally
python app.py
# Visit http://localhost:3000/
```

## 💻 Local Development

### Setup Virtual Environment

```bash
# Create virtual environment
python3 -m venv venv

# Activate it
source venv/bin/activate          # macOS/Linux
# OR
venv\Scripts\activate             # Windows
```

### Install Dependencies

```bash
pip install -r requirements.txt
```

Dependencies:
- **Flask 3.0.0** — Lightweight web framework
- **Gunicorn 21.2.0** — Production-grade WSGI server

### Run Locally

**Option 1: Development Server (Flask built-in)**
```bash
python app.py
# Server runs at http://localhost:3000
```

**Option 2: Production Server (Gunicorn)**
```bash
gunicorn -b 0.0.0.0:3000 app:app
# Server runs at http://localhost:3000 with production settings
```

### Test the Application

```bash
# Health check
curl http://localhost:3000/

# Personalized greeting
curl http://localhost:3000/john
curl http://localhost:3000/alice
```

Expected output:
```
Application Running
Welcome John
Welcome Alice
```

---

## 🐳 Docker Build & Run

### Build Image Locally

```bash
docker build -t welcome-app:local .
```

What happens:
1. Pulls Python 3.11-slim base image
2. Sets working directory to `/app`
3. Copies and installs `requirements.txt`
4. Copies application code
5. Exposes port 3000
6. Starts with Gunicorn WSGI server

### Run Container Locally

```bash
docker run --rm -p 3000:3000 welcome-app:local
```

Options explained:
- `--rm` — Automatically remove container when it exits
- `-p 3000:3000` — Map host port 3000 to container port 3000

### Test Container

```bash
# In another terminal
curl http://localhost:3000/
curl http://localhost:3000/jane
```

### Build and Push to ECR

Once infrastructure is deployed, push the image to Amazon ECR:

```bash
# Set AWS region
export AWS_REGION=${AWS_REGION:-us-east-1}

# Get AWS account ID
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

# Get ECR repository URI
REPO_URI=$(aws ecr describe-repositories \
  --repository-names welcome-app-repo \
  --query 'repositories[0].repositoryUri' \
  --output text)

echo "ECR Repository: $REPO_URI"

# Authenticate Docker with ECR
aws ecr get-login-password --region $AWS_REGION | \
  docker login --username AWS --password-stdin ${ACCOUNT_ID}.dkr.ecr.$AWS_REGION.amazonaws.com

# Build, tag, and push
docker build -t welcome-app:latest .
docker tag welcome-app:latest $REPO_URI:latest
docker push $REPO_URI:latest
```

**Important:** The ECS task definition references `${aws_ecr_repository.welcome-app-repo.repository_url}:latest`. Ensure the image is pushed before launching tasks.

---

## 🚀 Infrastructure Deployment

### Initialize Terraform

From the repository root:

```bash
terraform init
```

This:
- Initializes the working directory
- Downloads AWS provider plugin (~> 6.0)
- Configures remote state (S3 backend)

### Review Infrastructure Plan

```bash
terraform plan -out plan.tfplan
```

This shows all resources to be created:
- VPC and networking (subnets, IGW, route tables)
- Security groups
- ECR repository
- ECS cluster and task definition
- IAM roles and policies
- ALB (Application Load Balancer)

### Apply the Plan

```bash
# Using saved plan (recommended)
terraform apply plan.tfplan

# Or directly with auto-approval
terraform apply -auto-approve
```

This creates all AWS resources.

### Customize Deployment

Override default region:

```bash
terraform plan -var="aws_region=eu-west-1"
terraform apply -var="aws_region=eu-west-1"
```

### View Outputs

After `terraform apply`:

```bash
terraform output
```

Returns important values:
- ECR repository URL
- ECS cluster name
- VPC and subnet IDs
- Security group IDs

### Destroy Resources

To clean up and remove all resources (avoid unnecessary AWS charges):

```bash
terraform destroy -auto-approve
```

---

## 🔄 CI/CD Pipeline

### GitHub Actions Workflow

**File:** `terraform.yml`

**Trigger:** Push to `main` branch with `.tf` file changes

**Authentication:** AWS OIDC (no keys stored in GitHub secrets)

**Steps:**
1. **Checkout** — Clone repository
2. **Configure AWS Credentials** — Assume IAM role via OIDC
3. **Setup Terraform** — Install Terraform CLI
4. **Terraform Init** — Initialize working directory
5. **Format Check** — Validate HCL formatting (`terraform fmt -check`)
6. **Plan** — Review resource changes
7. **Apply** — Deploy approved changes

### Required GitHub Configuration

1. **Create IAM Role** for GitHub Actions (trust GitHub):

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::ACCOUNT_ID:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
        },
        "StringLike": {
          "token.actions.githubusercontent.com:sub": "repo:DennisOtchere/python-ecs-deployment:ref:refs/heads/main"
        }
      }
    }
  ]
}
```

2. **Attach Terraform permissions** to the role
3. **Update `terraform.yml`** with your role ARN

### Monitoring Pipeline

- View workflow runs in GitHub repository → **Actions** tab
- Logs show Terraform output for each step
- Failed steps prevent infrastructure changes (safe defaults)

---

## 🔧 Useful Commands

### Terraform Commands

```bash
# Format check (used in CI/CD)
terraform fmt -check

# Format and fix issues
terraform fmt -recursive

# Validate configuration
terraform validate

# Show current state
terraform show

# Refresh state from AWS
terraform refresh

# Destroy specific resource
terraform destroy -target=aws_ecs_task_definition.python_app_task
```

### AWS CLI Commands

```bash
# List ECR repositories
aws ecr describe-repositories

# Check ECS cluster status
aws ecs describe-clusters --clusters welcome-app-cluster

# List ECS task definitions
aws ecs list-task-definitions

# View Terraform state bucket
aws s3 ls python-app-terraform-state-vault-2026/
```

---

## 🐛 Troubleshooting

### Issue: Terraform state bucket already exists

**Error:** `BucketAlreadyExists`

**Solution:** Change bucket name in `state.tf` (must be globally unique)
```hcl
bucket = "my-unique-terraform-state-2026"
```

### Issue: ECR image pull fails in ECS

**Problem:** ECS task cannot pull image from ECR

**Solution:**
- Verify image was pushed: `aws ecr describe-images --repository-name welcome-app-repo`
- Check task execution role has ECR pull permission
- Verify security group allows egress to ECR endpoint

### Issue: Container port 3000 not accessible

**Problem:** Cannot reach application via ALB

**Solution:**
- Verify security group allows inbound on port 3000
- Check ALB target group health (AWS Console → EC2 → Target Groups)
- Review ECS task logs: `aws logs tail /ecs/python-app-task --follow`

### Issue: Terraform plan hangs

**Problem:** `terraform plan` takes too long

**Solution:**
```bash
# Add verbosity
TF_LOG=DEBUG terraform plan

# Check AWS API limits
# May need to wait or adjust credentials
```

### Issue: AWS credentials not found

**Error:** `NoCredentialsError`

**Solution:**
```bash
# Verify credentials are configured
aws sts get-caller-identity

# If using environment variables
echo $AWS_ACCESS_KEY_ID
echo $AWS_REGION
```

---

## 📚 Additional Resources

- [Flask Documentation](https://flask.palletsprojects.com/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest)
- [AWS ECS Best Practices](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/)
- [GitHub Actions OIDC](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect)
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)

---

## 📄 License

[MIT]

---

**Last Updated:** 2026-06-02  
**Repository:** [DennisOtchere/python-ecs-deployment](https://github.com/DennisOtchere/python-ecs-deployment)
