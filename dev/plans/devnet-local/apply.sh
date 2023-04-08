#!/bin/bash
set -eou pipefail
plan_dir="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

function tf() {
    terraform -chdir="${plan_dir}" "$@"
}

# Initialize terraform.
tf init -upgrade

# Create k8s cluster.
tf apply -auto-approve -target=module.cluster.module.k8s

# Initialize system components.
tf apply -auto-approve \
    -target=module.cluster.module.system.kubernetes_namespace.system \
    -target=module.cluster.module.system.helm_release.argocd

# Apply the rest.
tf apply -auto-approve
