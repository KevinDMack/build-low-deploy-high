#!/usr/bin/env bash
set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/common.sh"
environment="${1:-}"
shift || true
require_environment "${environment}"
ensure_tools
ensure_azure_context

terraform -chdir="${TF_DIR}" init
terraform -chdir="${TF_DIR}" destroy "$@"
