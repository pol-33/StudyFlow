#!/bin/bash

set -e

CLUSTER_NAME="project-local"
CONFIG_FILE="kind.config.yaml"

cd deployment

echo "--- Creating Cluster ---"
kind create cluster --name "${CLUSTER_NAME}" --config "${CONFIG_FILE}"

echo "--- Loading Images ---"
kind load docker-image \
  2026_1-project-12_01_a-backend:latest \
  2026_1-project-12_01_a-frontend:latest \
  --name "${CLUSTER_NAME}"

echo "--- Installing Ingress Nginx ---"
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

echo "--- Waiting for Ingress to be ready ---"
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=180s

echo "--- Applying Terraform ---"
terraform init
terraform apply -var-file values.tfvars -auto-approve