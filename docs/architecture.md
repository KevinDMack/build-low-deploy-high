# Architecture

This repository implements a build-low/deploy-high pattern for Azure Government (`AzureUSGovernment`) with a default region of `usgovarizona`.

## Folders

- `dev-machine/` contains the Packer template that builds the managed image used by the low environment virtual machines.
- `low-environment/` contains Terraform that targets an existing virtual network, deploys the managed-image virtual machines, and provisions private Azure OpenAI, Azure Container Registry, and Storage resources.
- `high-environment/` contains Terraform that targets an existing virtual network, deploys private Azure OpenAI, Azure Container Registry, and Storage resources, and attaches an outbound-deny NSG.
- `scripts/` contains Azure CLI and Terraform helper scripts.
- `docs/` contains solution documentation.

## Low environment

The low environment expects an existing VNet with `vm`, `aoai`, `acr`, `storage`, and optional `AzureBastionSubnet` subnets. Terraform deploys:

- Linux virtual machines from the managed image built by Packer.
- Azure OpenAI with a private endpoint on the `aoai` subnet.
- Azure Container Registry with a private endpoint on the `acr` subnet.
- Storage account with shared keys disabled, private endpoint on `storage`, and a managed identity role assignment.
- Optional Azure Bastion.

## High environment

The high environment expects an existing VNet with `aoai`, `acr`, `storage`, and optional `AzureBastionSubnet` subnets. Terraform deploys:

- Azure OpenAI with a private endpoint on the `aoai` subnet.
- Azure Container Registry with a private endpoint on the `acr` subnet.
- Storage account with shared keys disabled, private endpoint on `storage`, and a managed identity role assignment.
- An NSG associated with the private endpoint subnets to deny outbound Internet traffic.
- Optional Azure Bastion.
