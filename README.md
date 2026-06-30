# build-low-deploy-high

Azure Government build-low/deploy-high proof of concept built around Packer, Terraform, Azure CLI, and a dev container workflow.

## Repository layout

- `dev-machine/` - Packer template for the managed VM image.
- `low-environment/` - Terraform for the low-side VNet-connected VM and private service deployment.
- `high-environment/` - Terraform for the high-side private service deployment and outbound deny NSG.
- `scripts/` - Bash helpers for Terraform lifecycle operations and Azure Government network bootstrapping.
- `docs/` - Solution overview and usage guidance.
- `.devcontainer/` - Dev container definition with Azure CLI, Terraform, Packer, Node.js, npm, and Copilot CLI.
- `.vscode/` - VS Code tasks for the provided scripts.

See `/home/runner/work/build-low-deploy-high/build-low-deploy-high/docs/architecture.md` and `/home/runner/work/build-low-deploy-high/build-low-deploy-high/docs/usage.md` for details.
