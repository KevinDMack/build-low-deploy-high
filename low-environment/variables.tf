variable "prefix" {
  type        = string
  description = "Name prefix applied to deployed resources."
  default     = "bldldh-low"
}

variable "resource_group_name" {
  type        = string
  description = "Resource group where low environment resources are deployed."
}

variable "location" {
  type        = string
  description = "Azure Government region for the deployment."
  default     = "usgovarizona"
}

variable "vnet_name" {
  type        = string
  description = "Existing virtual network name used by the low environment."
}

variable "vnet_resource_group_name" {
  type        = string
  description = "Optional resource group containing the existing virtual network."
  default     = null
}

variable "vm_subnet_name" {
  type        = string
  description = "Subnet name for low environment virtual machines."
  default     = "vm"
}

variable "aoai_subnet_name" {
  type        = string
  description = "Subnet name for the Azure OpenAI private endpoint."
  default     = "aoai"
}

variable "acr_subnet_name" {
  type        = string
  description = "Subnet name for the container registry private endpoint."
  default     = "acr"
}

variable "storage_subnet_name" {
  type        = string
  description = "Subnet name for the storage account private endpoint."
  default     = "storage"
}

variable "bastion_subnet_name" {
  type        = string
  description = "Subnet name reserved for Azure Bastion."
  default     = "AzureBastionSubnet"
}

variable "image_id" {
  type        = string
  description = "Managed image ID produced from the dev-machine Packer build."
}

variable "vm_admin_username" {
  type        = string
  description = "Admin username applied to the low environment VMs."
  default     = "azureuser"
}

variable "vm_admin_ssh_public_key" {
  type        = string
  description = "SSH public key used for the low environment VMs."
}

variable "vm_count" {
  type        = number
  description = "Number of low environment VMs to deploy."
  default     = 1
}

variable "vm_size" {
  type        = string
  description = "VM size used for low environment virtual machines."
  default     = "Standard_D2s_v5"
}

variable "deploy_bastion" {
  type        = bool
  description = "Deploy Azure Bastion into the existing AzureBastionSubnet when true."
  default     = false
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to deployed resources."
  default     = {}
}
