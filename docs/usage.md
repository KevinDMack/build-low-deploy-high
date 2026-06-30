# Usage

## 1. Create the network foundations

```bash
/home/runner/work/build-low-deploy-high/build-low-deploy-high/scripts/create-foundations.sh
```

The script uses the currently logged-in Azure CLI credentials, switches to `AzureUSGovernment`, defaults to `usgovarizona`, and creates the expected resource groups, VNets, and subnets if they do not already exist.

## 2. Build the low-side image

```bash
cd /home/runner/work/build-low-deploy-high/build-low-deploy-high/dev-machine
packer init .
packer validate .
packer build .
```

Copy `dev-machine.auto.pkrvars.hcl.example` to a `.pkrvars.hcl` file and provide the target resource group names.

## 3. Deploy Terraform

Copy each `terraform.tfvars.example` to `terraform.tfvars` and update the values for your subscription.

```bash
/home/runner/work/build-low-deploy-high/build-low-deploy-high/scripts/init.sh low
/home/runner/work/build-low-deploy-high/build-low-deploy-high/scripts/validate.sh low
/home/runner/work/build-low-deploy-high/build-low-deploy-high/scripts/deploy.sh low

/home/runner/work/build-low-deploy-high/build-low-deploy-high/scripts/init.sh high
/home/runner/work/build-low-deploy-high/build-low-deploy-high/scripts/validate.sh high
/home/runner/work/build-low-deploy-high/build-low-deploy-high/scripts/deploy.sh high
```

Destroy either environment with the matching `destroy.sh` command.

## 4. Dev container

The dev container installs Azure CLI, Terraform, Packer, Node.js, npm, and GitHub Copilot CLI. VS Code tasks are included for each script in `/home/runner/work/build-low-deploy-high/build-low-deploy-high/.vscode/tasks.json`.
