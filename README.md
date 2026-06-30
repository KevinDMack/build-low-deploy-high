# build-low-deploy-high

Azure Government build-low/deploy-high proof of concept built around Packer, Terraform, Azure CLI, and a dev container workflow.

## Repository layout

| Folder | Purpose |
|--------|---------|
| `dev-machine/` | Packer template for the managed VM image |
| `low-environment/` | Terraform for the low-side VNet-connected VM and private service deployment |
| `high-environment/` | Terraform for the high-side private service deployment and outbound deny NSG |
| `scripts/` | Bash helpers for Terraform lifecycle operations and Azure Government network bootstrapping |
| `docs/` | Solution overview and usage guidance |
| `.devcontainer/` | Dev container definition with Azure CLI, Terraform, Packer, Node.js, and npm |
| `.vscode/` | VS Code tasks for the provided scripts |

## Prerequisites

- An **Azure Government** subscription (`AzureUSGovernment` cloud)
- [Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli) logged in (`az login`)
- [Terraform](https://developer.hashicorp.com/terraform/downloads) ≥ 1.0
- [Packer](https://developer.hashicorp.com/packer/downloads) (for building the VM image)
- [VS Code](https://code.visualstudio.com/) with the [Dev Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) extension (recommended)

> **Tip:** The included dev container installs all required tooling automatically. Open the repo in VS Code and select **Reopen in Container** to get started immediately.

## Getting started

### 1. Open the dev container (recommended)

Open this repository in VS Code, then use the command palette (`Ctrl+Shift+P`) and select **Dev Containers: Reopen in Container**. The container image includes Azure CLI, Terraform, Packer, Node.js, and npm.

### 2. Authenticate with Azure Government

```bash
az cloud set --name AzureUSGovernment
az login
```

### 3. Create the network foundations

```bash
./scripts/create-foundations.sh
```

This creates the expected resource groups, VNets, and subnets in `usgovarizona` (configurable via `DEFAULT_LOCATION`).

### 4. Build the low-side VM image

```bash
cd dev-machine
cp dev-machine.auto.pkrvars.hcl.example dev-machine.auto.pkrvars.hcl
# Edit the file with your resource group names
packer init .
packer validate .
packer build .
```

### 5. Deploy with Terraform

Copy each `terraform.tfvars.example` to `terraform.tfvars` and fill in your subscription values, then run:

```bash
# Low environment
./scripts/init.sh low
./scripts/validate.sh low
./scripts/deploy.sh low

# High environment
./scripts/init.sh high
./scripts/validate.sh high
./scripts/deploy.sh high
```

### 6. Tear down

```bash
./scripts/destroy.sh low
./scripts/destroy.sh high
```

## VS Code tasks

The repository includes pre-configured VS Code tasks (`.vscode/tasks.json`) that wrap the helper scripts. Run them via **Terminal → Run Task…** or `Ctrl+Shift+P` → **Tasks: Run Task**.

| Task | Description |
|------|-------------|
| **Create foundations** | Runs `create-foundations.sh` to provision resource groups, VNets, and subnets for both environments |
| **Low: init** | `terraform init` for the low environment |
| **Low: validate** | `terraform validate` for the low environment |
| **Low: deploy** | `terraform apply` for the low environment |
| **Low: destroy** | `terraform destroy` for the low environment |
| **High: init** | `terraform init` for the high environment |
| **High: validate** | `terraform validate` for the high environment |
| **High: deploy** | `terraform apply` for the high environment |
| **High: destroy** | `terraform destroy` for the high environment |

## Further reading

- [Architecture overview](docs/architecture.md)
- [Detailed usage guide](docs/usage.md)
