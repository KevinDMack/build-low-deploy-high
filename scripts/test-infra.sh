#!/usr/bin/env bash
set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/common.sh"
environment="${1:-}"
mode="${2:-validate}"
shift 2 || true

require_environment "${environment}"
command -v terraform >/dev/null

terraform -chdir="${TF_DIR}" fmt -check -recursive
terraform -chdir="${TF_DIR}" init -backend=false "$@"
terraform -chdir="${TF_DIR}" validate

if [[ "${mode}" != "drift" ]]; then
  exit 0
fi

if [[ ! -f "${TF_DIR}/terraform.tfvars" ]]; then
  echo "Missing ${TF_DIR}/terraform.tfvars for drift checks." >&2
  exit 1
fi

ensure_tools
ensure_azure_context
terraform -chdir="${TF_DIR}" init "$@"

set +e
terraform -chdir="${TF_DIR}" plan -refresh-only -detailed-exitcode -input=false -lock=false
plan_exit_code=$?
set -e

case "${plan_exit_code}" in
  0)
    echo "No drift detected in ${environment} environment."
    ;;
  2)
    echo "Drift detected in ${environment} environment." >&2
    exit 1
    ;;
  *)
    exit "${plan_exit_code}"
    ;;
esac
