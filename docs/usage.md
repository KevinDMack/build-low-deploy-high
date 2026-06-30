# Usage

## 1. Create the network foundations

```bash
./scripts/create-foundations.sh
```

The script uses the currently logged-in Azure CLI credentials, switches to `AzureUSGovernment`, defaults to `usgovarizona`, and creates the expected resource groups, VNets, and subnets if they do not already exist.

## 2. Build the low-side image

```bash
cd dev-machine
packer init .
packer validate .
packer build .
```

Copy `dev-machine.auto.pkrvars.hcl.example` to a `.pkrvars.hcl` file and provide the target resource group names.

## 3. Deploy Terraform

Copy each `terraform.tfvars.example` to `terraform.tfvars` and update the values for your subscription.

```bash
./scripts/init.sh low
./scripts/validate.sh low
./scripts/deploy.sh low

./scripts/init.sh high
./scripts/validate.sh high
./scripts/deploy.sh high
```

Destroy either environment with the matching `destroy.sh` command.

## 4. Dev container

The dev container installs Azure CLI, Terraform, Packer, Node.js, and npm. VS Code tasks are included for each script — see `.vscode/tasks.json` or the [VS Code tasks section](../README.md#vs-code-tasks) in the README.

## 5. VS Code tasks

Instead of running scripts directly, you can use the built-in VS Code tasks:

1. Open the command palette (`Ctrl+Shift+P`) and select **Tasks: Run Task**.
2. Choose from the available tasks:

| Task | Script | Description |
|------|--------|-------------|
| Create foundations | `create-foundations.sh` | Provision resource groups, VNets, and subnets |
| Low: init | `init.sh low` | Initialize Terraform for the low environment |
| Low: validate | `validate.sh low` | Validate Terraform configuration |
| Low: deploy | `deploy.sh low` | Apply Terraform plan |
| Low: destroy | `destroy.sh low` | Destroy low environment resources |
| High: init | `init.sh high` | Initialize Terraform for the high environment |
| High: validate | `validate.sh high` | Validate Terraform configuration |
| High: deploy | `deploy.sh high` | Apply Terraform plan |
| High: destroy | `destroy.sh high` | Destroy high environment resources |
