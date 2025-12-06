# Local Deployment Guide

This document explains the purpose of the `deployment/` directory, how the local deployment script operates, prerequisites, step-by-step execution, troubleshooting, security considerations, and best practices. All instructions are verified against the actual files in this repository.

## Purpose and Functionality

- The `deployment/` directory contains Terraform configurations and module definitions that provision Kubernetes resources on a local Kind cluster.
- It orchestrates three primary components:
  - Backend (Django) deployment, service, and config map
  - Frontend (Vue/Vite) deployment, service, config map, and Ingress
  - PostgreSQL deployment and service with optional init SQL
- The local deployment entrypoint is the script at `../local_deployment.sh`, which automates cluster creation, image loading, Ingress installation, and Terraform apply.

### What `deployment/` contains

- Kubernetes provider and namespace:
  - `deployment/main.tf` configures the Kubernetes provider to use `~/.kube/config` and creates namespace `project-local` (deployment/main.tf, deployment/main.tf).
- Top-level modules:
  - `deployment/backend.tf` wires the backend module with image name and environment configuration inputs (deployment/backend.tf).
  - `deployment/frontend.tf` wires the frontend module and depends on backend (deployment/frontend.tf).
  - `deployment/db.tf` provisions PostgreSQL and an init SQL config map (deployment/db.tf, deployment/db.tf).
- Module implementations:
  - Frontend: `deployment/module/frontend/`
    - Deployment using image `${var.image_name}:latest` exposing port `5173` (deployment/module/frontend/frontend.tf).
    - Service exposing `5173` (deployment/module/frontend/service.tf).
    - Ingress routes `"/"` to frontend service on `5173` and `"/api"` to backend service on `8000` (deployment/module/frontend/ingress.tf, deployment/module/frontend/ingress.tf), with TLS optional (deployment/module/frontend/ingress.tf). Ingress host defaults to `localhost` (deployment/module/frontend/variables.tf).
  - Backend: `deployment/module/backend/`
    - Deployment using image `${var.image_name}:latest` exposing `8000` (deployment/module/backend/backend.tf).
    - Service exposing `8000` (deployment/module/backend/service.tf).
    - Config map providing environment variables (deployment/module/backend/backend.tf).
  - Postgres: `deployment/module/postgres/`
    - Deployment and service on `5432`, with liveness probe and optional init SQL via config maps (deployment/module/postgres/main.tf, deployment/module/postgres/main.tf, deployment/module/postgres/main.tf).
    - Defaults to image `postgres:16.3-alpine3.20` (deployment/module/postgres/main.tf).
- Cluster configuration for Kind:
  - `deployment/kind.config.yaml` enables Ingress readiness and maps host ports `80/443` (deployment/kind.config.yaml).
- Variables and defaults:
  - `deployment/variables.tf` declares Terraform variables such as `image_name`, backend env vars, and `vite_api_base_url` (deployment/variables.tf, deployment/variables.tf).

### How `local_deployment.sh` operates

- Location: `../local_deployment.sh`
- Flow (verified against file):
  - Creates a Kind cluster named `project-local` using `deployment/kind.config.yaml` (local_deployment.sh).
  - Loads local Docker images `2026_1-project-12_01_a-backend:latest` and `2026_1-project-12_01_a-frontend:latest` into the Kind cluster (local_deployment.sh).
  - Installs NGINX Ingress controller and waits until the controller pod is ready (local_deployment.sh).
  - Runs `terraform init` and `terraform apply -var-file values.tfvars -auto-approve` inside `deployment/` (local_deployment.sh).
- Notes:
  - Terraform provider uses the current kubeconfig context at `~/.kube/config` (deployment/main.tf). `kind create cluster` sets context automatically.
  - The script uses `set -e` to stop on first error (local_deployment.sh).

## Execution Instructions

### Required permissions

- Ensure the script is executable:

```bash
chmod +x ./local_deployment.sh
```

- Docker Desktop must be running and have permission to access the Docker daemon.
- Ports `80` and `443` on your host must be free because Kind maps them (deployment/kind.config.yaml).

### Command syntax and parameters

- Basic usage (no parameters):

```bash
./local_deployment.sh
```

- The script does not accept CLI parameters. To change cluster name or Kind config path, edit `CLUSTER_NAME` and `CONFIG_FILE` at the top of the script (local_deployment.sh).

### Pre-run checklist

- Build and tag the required local Docker images so Kind can load them:

```bash
# Backend (dev target, exposes 8000)
docker build -t 2026_1-project-12_01_a-backend:latest -f backend/Dockerfile --target dev backend

# Frontend (dev target, exposes 5173)
docker build -t 2026_1-project-12_01_a-frontend:latest -f frontend/Dockerfile --target dev frontend
```

- Create `deployment/values.tfvars` referenced by the script. If this file is missing, `terraform apply` will fail.
  - Sample `deployment/values.tfvars` (variables match `deployment/variables.tf`):

```hcl
# Image naming
image_name = "2026_1-project-12_01_a"

# Backend env
secret_key = "change-me"
debug = "True"
allowed_hosts = "localhost,127.0.0.1"
cors_allowed_origins = "http://localhost,http://127.0.0.1"
access_token_lifetime_minutes = "60"
refresh_token_lifetime_days = "1"

# Frontend env
vite_api_base_url = "http://localhost"

# Database
db_username = "backend"
db_password = "backend"
```

### Run the deployment

```bash
./local_deployment.sh
```

### Expected output and success indicators

- You will see echo banners for each step and CLI outputs:
  - Kind cluster created successfully (local_deployment.sh).
  - Images loaded into Kind (local_deployment.sh).
  - Ingress controller applied and pod becomes Ready (local_deployment.sh).
  - Terraform init and apply succeed with resources created.
- Post-deploy verification:

```bash
# Ensure namespace exists
kubectl get ns project-local

# Check pods
kubectl get pods -n project-local

# Check services
kubectl get svc -n project-local

# Check ingress
kubectl get ingress -n project-local
```

- Access via browser:
  - Frontend: `http://localhost/` (Ingress routes `/` to the frontend service on port 5173).
  - Backend API: `http://localhost/api` (Ingress routes `/api` to backend service on 8000).

## Package Requirements

### Dependencies

- Docker Desktop (to build and host images and run Kind)
- Kind (Kubernetes-in-Docker)
- kubectl (Kubernetes CLI)
- Terraform (HashiCorp)
- Internet access to apply the Ingress NGINX manifest URL

### Installation instructions (macOS)

```bash
# Install Kind
brew install kind

# Install kubectl
brew install kubernetes-cli

# Install Terraform
brew tap hashicorp/tap
brew install hashicorp/tap/terraform

# Install Docker Desktop (manual)
# https://www.docker.com/products/docker-desktop/
```

### Version requirements and compatibility notes

- Terraform: verified with `1.5.x` (deployment state indicates 1.5.7 was used).
- Kind: recommended `v0.20+`; any recent version that supports the provided `Cluster` config should work.
- kubectl: match the cluster version Kind provides; `v1.27+` recommended.
- Docker: recent versions `24+` recommended.
- Ingress NGINX is installed from the `main` branch manifest (local_deployment.sh:20); network access required.

## Additional Information

### Common issues and troubleshooting

- `terraform apply` fails with missing `values.tfvars`:
  - Ensure `deployment/values.tfvars` exists and is readable.
- Images not found when deploying:
  - Confirm you built and tagged images exactly as `2026_1-project-12_01_a-backend:latest` and `2026_1-project-12_01_a-frontend:latest` (local_deployment.sh:14-17).
  - Verify images are loaded into Kind: `docker images` then re-run the script.
- Ingress not ready / timeouts:
  - Check controller pods: `kubectl get pods -n ingress-nginx`.
  - Ensure ports `80/443` are not in use by other services on the host.
- Terraform cannot connect to the cluster:
  - Verify kubeconfig and context: `kubectl config current-context` should point to the Kind cluster (deployment/main.tf).
- Frontend opens but API 404/503:
  - Check backend service: `kubectl get svc backend-service -n project-local` and pods: `kubectl get pods -n project-local`.
  - Confirm Ingress routes `/api` to backend (deployment/module/frontend/ingress.tf).

### Security considerations

- Secrets and config:
  - Backend uses a ConfigMap for environment values, not Kubernetes Secrets (deployment/module/backend/backend.tf). Avoid placing sensitive values in plain text; consider switching to Secrets for production.
- Ingress and CORS:
  - Ingress enables CORS with `*` and disables SSL redirect for local development (deployment/module/frontend/ingress.tf). Restrict origins for non-local usage.
- Ports and exposure:
  - Kind maps host ports `80/443`; ensure your local machine is secure and no conflicting services are exposed (deployment/kind.config.yaml).

### Best practices for deployment

- Use development targets for Docker images to match expected ports:
  - Backend dev exposes `8000` (backend/Dockerfile).
  - Frontend dev exposes `5173` (frontend/Dockerfile).
- Keep `values.tfvars` in `.gitignore` if storing sensitive overrides.
- Re-run `terraform apply` after image rebuilds if you changed environment variables.
- To update deployments with new images:
  - Rebuild images, then `kind load docker-image …` or re-run the script.
- Cleanup when done:

```bash
# Remove Kubernetes resources
(cd deployment && terraform destroy -var-file values.tfvars -auto-approve)

# Delete Kind cluster
kind delete cluster --name project-local
```

## Example Usage Scenarios

- Fresh local setup:
  1. Build backend and frontend images (dev targets).
  2. Create `deployment/values.tfvars` with desired overrides.
  3. Run `./local_deployment.sh`.
  4. Visit `http://localhost/` and test the UI and `/api`.

- Customize API base URL for frontend:
  - Set `vite_api_base_url` in `values.tfvars` (deployment/variables.tf). Re-apply Terraform or re-run the script.

- Quick verification commands:

```bash
kubectl get all -n project-local
kubectl describe ingress app-ingress -n project-local
kubectl logs deploy/backend -n project-local
kubectl logs deploy/frontend -n project-local
```

## File References

- Script steps: `local_deployment.sh`, `local_deployment.sh`, `local_deployment.sh`, `local_deployment.sh`
- Provider and namespace: `deployment/main.tf`, `deployment/main.tf`
- Variables: `deployment/variables.tf`, `deployment/variables.tf`
- Kind config: `deployment/kind.config.yaml`
- Frontend: `deployment/module/frontend/frontend.tf`, `deployment/module/frontend/service.tf`, `deployment/module/frontend/ingress.tf`, `deployment/module/frontend/ingress.tf`, `deployment/module/frontend/variables.tf`
- Backend: `deployment/module/backend/backend.tf`, `deployment/module/backend/service.tf`, `deployment/module/backend/backend.tf`
- Postgres: `deployment/module/postgres/main.tf`, `deployment/module/postgres/main.tf`, `deployment/module/postgres/main.tf`, `deployment/module/postgres/main.tf`
