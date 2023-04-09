#!/bin/bash
set -eo pipefail
plan_dir="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
set -a; source "${plan_dir}/.env"; set +a

function tf() {
    terraform -chdir="${plan_dir}" "$@"
}

terraform init -upgrade \
     -backend-config="bucket=${TFSTATE_AWS_BUCKET}" \
     -backend-config="key=${PLAN}/terraform.tfstate" \
     -backend-config="encrypt=true" \
     -backend-config="dynamodb_table=${TFSTATE_AWS_BUCKET}-locking" \
     -backend-config="region=${TFSTATE_AWS_REGION}"

tf apply "$@"
