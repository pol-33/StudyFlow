#!/usr/bin/env bash
set -euo pipefail

CLUSTER_NAME="${CLUSTER_NAME:-studyflow}"
REGION="${REGION:-eu-south-2}"
VERSION="${VERSION:-1.33}"
VPC_ID="${VPC_ID:-vpc-0a033905148a52e39}"
PRIVATE_SUBNET_IDS="${PRIVATE_SUBNET_IDS:-}"
CREATE_NODEGROUP="${CREATE_NODEGROUP:-false}"
NODEGROUP_NAME="${NODEGROUP_NAME:-${CLUSTER_NAME}-nodegroup}"
NODEGROUP_MIN="${NODEGROUP_MIN:-5}"
NODEGROUP_MAX="${NODEGROUP_MAX:-10}"
NODEGROUP_DESIRED="${NODEGROUP_DESIRED:-5}"
NODEGROUP_INSTANCE_TYPE="${NODEGROUP_INSTANCE_TYPE:-t3.micro}"
NODEGROUP_VOLUME_SIZE="${NODEGROUP_VOLUME_SIZE:-20}"
NODEGROUP_MAX_PODS="${NODEGROUP_MAX_PODS:-30}"
IAM_CLUSTER_ROLE_NAME="${IAM_CLUSTER_ROLE_NAME:-${CLUSTER_NAME}-ClusterRole}"
IAM_NODE_ROLE_NAME="${IAM_NODE_ROLE_NAME:-${CLUSTER_NAME}-NodeRole}"

require_cmds() {
  for c in aws eksctl kubectl; do
    command -v "$c" >/dev/null 2>&1 || { echo "Missing dependency: $c"; exit 1; }
  done
}

exists_vpc() {
  aws ec2 describe-vpcs --region "$REGION" --vpc-ids "$VPC_ID" >/dev/null 2>&1
}

get_private_subnets() {
  if [ -n "$PRIVATE_SUBNET_IDS" ]; then echo "$PRIVATE_SUBNET_IDS"; return; fi
  aws ec2 describe-subnets --region "$REGION" --filters "Name=vpc-id,Values=$VPC_ID" --query "Subnets[?MapPublicIpOnLaunch==\`false\`].SubnetId" --output text | tr '\t' ','
}

exists_cluster() {
  aws eks describe-cluster --region "$REGION" --name "$CLUSTER_NAME" >/dev/null 2>&1
}

current_cluster_version() {
  aws eks describe-cluster --region "$REGION" --name "$CLUSTER_NAME" --query "cluster.version" --output text
}

create_cluster() {
  subnets="$(get_private_subnets)"
  if [ -z "$subnets" ]; then echo "No private subnets found for $VPC_ID"; exit 1; fi
  eksctl create cluster --name "$CLUSTER_NAME" --region "$REGION" --version "$VERSION" --vpc-private-subnets "$subnets" --without-nodegroup
}

upgrade_cluster_version_if_needed() {
  cur="$(current_cluster_version)"
  if [ "$cur" != "$VERSION" ]; then
    aws eks update-cluster-version --region "$REGION" --name "$CLUSTER_NAME" --kubernetes-version "$VERSION" >/dev/null
    echo "Cluster version updated from $cur to $VERSION"
  else
    echo "Cluster already at version $VERSION"
  fi
}

exists_nodegroup() {
  aws eks list-nodegroups --region "$REGION" --cluster-name "$CLUSTER_NAME" --query "nodegroups[]" --output text | tr '\t' '\n' | grep -Fx "$NODEGROUP_NAME" >/dev/null 2>&1
}

create_nodegroup() {
  eksctl create nodegroup --cluster "$CLUSTER_NAME" --region "$REGION" --name "$NODEGROUP_NAME" --nodes "$NODEGROUP_DESIRED" --nodes-min "$NODEGROUP_MIN" --nodes-max "$NODEGROUP_MAX" --managed --node-type "$NODEGROUP_INSTANCE_TYPE" --node-volume-size "$NODEGROUP_VOLUME_SIZE" --max-pods-per-node "$NODEGROUP_MAX_PODS"
}

update_nodegroup_if_needed() {
  eksctl scale nodegroup --cluster "$CLUSTER_NAME" --region "$REGION" --name "$NODEGROUP_NAME" --nodes "$NODEGROUP_DESIRED" >/dev/null 2>&1 || true
  eksctl upgrade nodegroup --cluster "$CLUSTER_NAME" --region "$REGION" --name "$NODEGROUP_NAME" --approve >/dev/null 2>&1 || true
  echo "Nodegroup $NODEGROUP_NAME updated"
}

ensure_policy_attached() {
  role="$1"; arn="$2"
  aws iam list-attached-role-policies --role-name "$role" --query "AttachedPolicies[?PolicyArn=='$arn'].PolicyArn" --output text | grep -q "$arn" || aws iam attach-role-policy --role-name "$role" --policy-arn "$arn" >/dev/null
}

ensure_iam_cluster_role() {
  if aws iam get-role --role-name "$IAM_CLUSTER_ROLE_NAME" >/dev/null 2>&1; then
    ensure_policy_attached "$IAM_CLUSTER_ROLE_NAME" arn:aws:iam::aws:policy/AmazonEKSClusterPolicy
    ensure_policy_attached "$IAM_CLUSTER_ROLE_NAME" arn:aws:iam::aws:policy/AmazonEKSServicePolicy
    echo "IAM role $IAM_CLUSTER_ROLE_NAME exists"
  else
    aws iam create-role --role-name "$IAM_CLUSTER_ROLE_NAME" --assume-role-policy-document '{"Version":"2012-10-17","Statement":[{"Effect":"Allow","Principal":{"Service":"eks.amazonaws.com"},"Action":"sts:AssumeRole"}]}' >/dev/null
    ensure_policy_attached "$IAM_CLUSTER_ROLE_NAME" arn:aws:iam::aws:policy/AmazonEKSClusterPolicy
    ensure_policy_attached "$IAM_CLUSTER_ROLE_NAME" arn:aws:iam::aws:policy/AmazonEKSServicePolicy
    echo "IAM role $IAM_CLUSTER_ROLE_NAME created"
  fi
}

ensure_iam_node_role() {
  if aws iam get-role --role-name "$IAM_NODE_ROLE_NAME" >/dev/null 2>&1; then
    ensure_policy_attached "$IAM_NODE_ROLE_NAME" arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy
    ensure_policy_attached "$IAM_NODE_ROLE_NAME" arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly
    ensure_policy_attached "$IAM_NODE_ROLE_NAME" arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy
    echo "IAM role $IAM_NODE_ROLE_NAME exists"
  else
    aws iam create-role --role-name "$IAM_NODE_ROLE_NAME" --assume-role-policy-document '{"Version":"2012-10-17","Statement":[{"Effect":"Allow","Principal":{"Service":"ec2.amazonaws.com"},"Action":"sts:AssumeRole"}]}' >/dev/null
    ensure_policy_attached "$IAM_NODE_ROLE_NAME" arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy
    ensure_policy_attached "$IAM_NODE_ROLE_NAME" arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly
    ensure_policy_attached "$IAM_NODE_ROLE_NAME" arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy
    echo "IAM role $IAM_NODE_ROLE_NAME created"
  fi
}

ensure_kubeconfig() {
  aws eks update-kubeconfig --region "$REGION" --name "$CLUSTER_NAME" >/dev/null
}

apply_k8s_manifests_if_present() {
  if [ -d "deployment" ]; then
    for f in deployment/*.yaml; do
      [ -f "$f" ] || continue
      kubectl apply -f "$f"
    done
  fi
}

require_cmds

if exists_vpc; then echo "VPC $VPC_ID found"; else echo "VPC $VPC_ID not found"; exit 1; fi

ensure_iam_cluster_role
ensure_iam_node_role

if exists_cluster; then
  echo "Cluster $CLUSTER_NAME already exists"
  upgrade_cluster_version_if_needed
else
  echo "Creating cluster $CLUSTER_NAME"
  create_cluster
  echo "Cluster $CLUSTER_NAME created"
fi

if [ "$CREATE_NODEGROUP" = "true" ]; then
  if exists_nodegroup; then
    echo "Nodegroup $NODEGROUP_NAME already exists"
    update_nodegroup_if_needed
  else
    echo "Creating nodegroup $NODEGROUP_NAME"
    create_nodegroup
    echo "Nodegroup $NODEGROUP_NAME created"
  fi
else
  echo "Nodegroup creation skipped"
fi

ensure_kubeconfig
apply_k8s_manifests_if_present

echo "Deployment completed"

echo "--- Installing Ingress Nginx ---"
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

echo "--- Waiting for Ingress to be ready ---"
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=180s
  
cd deployment

terraform init
terraform apply -var-file values.tfvars -auto-approve
