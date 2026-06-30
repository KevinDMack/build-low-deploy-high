#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "${SCRIPT_DIR}/.." && pwd)"
DEFAULT_LOCATION="${DEFAULT_LOCATION:-usgovarizona}"

usage() {
  echo "Usage: $0 <low|high> [terraform args...]" >&2
}

require_environment() {
  if [[ $# -ne 1 ]]; then
    usage
    exit 1
  fi

  case "$1" in
    low) TF_DIR="${REPO_ROOT}/low-environment" ;;
    high) TF_DIR="${REPO_ROOT}/high-environment" ;;
    *)
      usage
      exit 1
      ;;
  esac

  export TF_IN_AUTOMATION=1
  export ARM_ENVIRONMENT=usgovernment
  export AZURE_CORE_CLOUD=AzureUSGovernment
}

ensure_tools() {
  command -v az >/dev/null
  command -v terraform >/dev/null
}

ensure_azure_context() {
  az cloud set --name AzureUSGovernment >/dev/null
  az account show >/dev/null
}
