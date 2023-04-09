#!/bin/bash
set -eo pipefail
plan_dir="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
set -a; source "${plan_dir}/.env"; set +a

function tf() {
    terraform -chdir="${plan_dir}" "$@"
}

# Initialize terraform.
terraform init -upgrade \
     -backend-config="bucket=${TFSTATE_AWS_BUCKET}" \
     -backend-config="key=${PLAN}/terraform.tfstate" \
     -backend-config="encrypt=true" \
     -backend-config="dynamodb_table=${TFSTATE_AWS_BUCKET}-locking" \
     -backend-config="region=${TFSTATE_AWS_REGION}"

# Create cluster and container registry.
tf apply -auto-approve \
    -target=module.cluster.random_string.name
tf apply -auto-approve \
    -target=module.cluster.random_string.name \
    -target=module.cluster.module.k8s \
    -target=module.cluster.module.ecr_node_repo
tf apply -auto-approve \
    -target=module.cluster.module.system.kubernetes_namespace.system \
    -target=module.cluster.module.system.helm_release.argocd
echo

# Apply the rest.
tf apply -auto-approve
