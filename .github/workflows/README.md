# GitHub Actions CI/CD Pipeline

This document explains the automated CI/CD pipeline for deploying StudyFlow to Amazon EKS.

## Overview

The pipeline automatically builds Docker images and deploys them to an Amazon EKS (Elastic Kubernetes Service) cluster whenever code is pushed to the `main` branch.

```
┌─────────────┐     ┌─────────────────┐     ┌─────────────────┐     ┌─────────────┐
│   Push to   │────▶│  Build Docker   │────▶│  Push to ECR    │────▶│  Deploy to  │
│    main     │     │     Images      │     │                 │     │     EKS     │
└─────────────┘     └─────────────────┘     └─────────────────┘     └─────────────┘
```

## Workflow File

**Location:** `.github/workflows/deploy.yml`

## Pipeline Jobs

### Job 1: `build-and-push`

Builds and pushes Docker images to Amazon ECR (Elastic Container Registry).

| Step | Description |
|------|-------------|
| Checkout code | Clones the repository |
| Configure AWS credentials | Sets up AWS authentication using secrets |
| Login to Amazon ECR | Authenticates with the container registry |
| Build Backend image | Builds the Django backend Docker image |
| Build Frontend image | Builds the Vue.js frontend Docker image |
| Push images | Pushes images with both `SHA` and `latest` tags |

### Job 2: `deploy-to-eks`

Deploys the new images to the Kubernetes cluster.

| Step | Description |
|------|-------------|
| Checkout code | Clones the repository |
| Configure AWS credentials | Sets up AWS authentication |
| Login to Amazon ECR | Authenticates with the container registry |
| Update kubeconfig | Configures kubectl to connect to EKS cluster |
| Verify EKS access | Confirms connectivity to the cluster |
| Deploy to Kubernetes | Updates deployment images using `kubectl set image` |
| Verify deployment | Waits for rollout to complete successfully |

## Environment Variables

| Variable | Value | Description |
|----------|-------|-------------|
| `AWS_REGION` | `eu-south-2` | AWS region for all resources |
| `ECR_REPOSITORY_BACKEND` | `studyflow-backend` | ECR repository for backend image |
| `ECR_REPOSITORY_FRONTEND` | `studyflow-frontend` | ECR repository for frontend image |
| `EKS_CLUSTER_NAME` | `studyflow` | Name of the EKS cluster |

## Required GitHub Secrets

Configure these secrets in your repository settings (`Settings > Secrets and variables > Actions`):

| Secret | Description |
|--------|-------------|
| `AWS_ACCESS_KEY_ID` | AWS IAM access key with ECR and EKS permissions |
| `AWS_SECRET_ACCESS_KEY` | AWS IAM secret access key |

### Required IAM Permissions

The AWS credentials must have the following permissions:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "ecr:PutImage",
        "ecr:InitiateLayerUpload",
        "ecr:UploadLayerPart",
        "ecr:CompleteLayerUpload"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "eks:DescribeCluster"
      ],
      "Resource": "arn:aws:eks:eu-south-2:*:cluster/studyflow"
    }
  ]
}
```

## Prerequisites

Before running this workflow, ensure the following infrastructure exists:

### 1. AWS Infrastructure
- [ ] EKS cluster named `studyflow` in `eu-south-2`
- [ ] ECR repositories:
  - `studyflow-backend`
  - `studyflow-frontend`
- [ ] IAM user/role with required permissions

### 2. Kubernetes Resources
- [ ] Namespace `studyflow` exists
- [ ] Deployment `backend` exists in the namespace
- [ ] Deployment `frontend` exists in the namespace

> **Note:** These resources are created by Terraform in the `deployment/` folder. Run Terraform first before using this workflow.

## Image Tagging Strategy

Each build creates two tags per image:

| Tag | Purpose |
|-----|---------|
| `<git-sha>` | Unique identifier for each commit (e.g., `a1b2c3d4...`) |
| `latest` | Always points to the most recent build |

Example:
```
123456789.dkr.ecr.eu-south-2.amazonaws.com/studyflow-backend:abc123def
123456789.dkr.ecr.eu-south-2.amazonaws.com/studyflow-backend:latest
```

## Deployment Strategy

The workflow uses a **rolling update** strategy:

1. `kubectl set image` updates the deployment with the new image
2. Kubernetes gradually replaces old pods with new ones
3. `kubectl rollout status` waits for the rollout to complete (timeout: 5 minutes)

If the deployment fails, Kubernetes automatically rolls back to the previous version.

## Troubleshooting

### Common Errors

#### "No cluster found for name: studyflow"
**Cause:** EKS cluster doesn't exist or wrong region
**Solution:** 
- Verify cluster exists: `aws eks list-clusters --region eu-south-2`
- Run Terraform to create infrastructure

#### "The repository does not exist"
**Cause:** ECR repository hasn't been created
**Solution:** Create ECR repositories manually or via Terraform:
```bash
aws ecr create-repository --repository-name studyflow-backend --region eu-south-2
aws ecr create-repository --repository-name studyflow-frontend --region eu-south-2
```

#### "deployment not found"
**Cause:** Kubernetes deployments don't exist in the namespace
**Solution:** Run Terraform to create initial deployments, or apply Kubernetes manifests manually

#### "Unauthorized" or "Access Denied"
**Cause:** AWS credentials missing or insufficient permissions
**Solution:** 
- Verify GitHub secrets are configured correctly
- Check IAM permissions include ECR and EKS access

### Viewing Logs

1. Go to the **Actions** tab in your GitHub repository
2. Click on the failed workflow run
3. Expand the failed step to see detailed logs

### Manual Deployment

If the workflow fails, you can deploy manually:

```bash
# Configure kubectl
aws eks update-kubeconfig --name studyflow --region eu-south-2

# Check current deployments
kubectl get deployments -n studyflow

# Manually update image
kubectl set image deployment/backend backend-backend=<ECR_URI>:latest -n studyflow
kubectl set image deployment/frontend frontend=<ECR_URI>:latest -n studyflow

# Watch rollout
kubectl rollout status deployment/backend -n studyflow
kubectl rollout status deployment/frontend -n studyflow
```

## Architecture Diagram

```
GitHub Repository
       │
       ▼ (push to main)
┌──────────────────────────────────────────────────────────┐
│                    GitHub Actions                         │
│  ┌─────────────────────┐    ┌─────────────────────────┐  │
│  │   build-and-push    │───▶│     deploy-to-eks       │  │
│  │                     │    │                         │  │
│  │ • Build backend     │    │ • Update kubeconfig     │  │
│  │ • Build frontend    │    │ • kubectl set image     │  │
│  │ • Push to ECR       │    │ • Verify rollout        │  │
│  └─────────────────────┘    └─────────────────────────┘  │
└──────────────────────────────────────────────────────────┘
       │                              │
       ▼                              ▼
┌──────────────┐              ┌──────────────────┐
│  Amazon ECR  │              │   Amazon EKS     │
│              │              │                  │
│ • backend    │◀─────────────│ • backend pod    │
│ • frontend   │   (pull)     │ • frontend pod   │
└──────────────┘              └──────────────────┘
```

## Related Documentation

- [Amazon EKS User Guide](https://docs.aws.amazon.com/eks/latest/userguide/)
- [Amazon ECR User Guide](https://docs.aws.amazon.com/AmazonECR/latest/userguide/)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Kubernetes Deployments](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)
