packer {
  required_plugins {
    azure = {
      source  = "github.com/hashicorp/azure"
      version = ">= 2.2.0"
    }
  }
}

variable "build_resource_group_name" {
  type        = string
  description = "Temporary resource group used while building the image."
}

variable "location" {
  type        = string
  description = "Azure Government region for the image build."
  default     = "usgovarizona"
}

variable "managed_image_name" {
  type        = string
  description = "Name of the managed image produced by Packer."
  default     = "build-low-deploy-high-dev-image"
}

variable "managed_image_resource_group_name" {
  type        = string
  description = "Resource group that stores the managed image."
}

variable "ssh_username" {
  type        = string
  description = "SSH username used during the image build."
  default     = "azureuser"
}

variable "vm_size" {
  type        = string
  description = "VM size used while building the image."
  default     = "Standard_D2s_v5"
}

source "azure-arm" "dev_machine" {
  build_resource_group_name         = var.build_resource_group_name
  cloud_environment_name            = "AzureUSGovernmentCloud"
  image_offer                       = "0001-com-ubuntu-server-jammy"
  image_publisher                   = "Canonical"
  image_sku                         = "22_04-lts-gen2"
  location                          = var.location
  managed_image_name                = var.managed_image_name
  managed_image_resource_group_name = var.managed_image_resource_group_name
  os_type                           = "Linux"
  ssh_username                      = var.ssh_username
  use_azure_cli_auth                = true
  vm_size                           = var.vm_size
}

build {
  name    = "dev-machine"
  sources = ["source.azure-arm.dev_machine"]

  provisioner "shell" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y ca-certificates curl git unzip"
    ]
  }
}
