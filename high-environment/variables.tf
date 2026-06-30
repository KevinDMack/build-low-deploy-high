variable "prefix" {
  type        = string
  description = "Name prefix applied to deployed resources."
  default     = "bldldh-high"
}

variable "resource_group_name" {
  type        = string
  description = "Resource group where high environment resources are deployed."
}

variable "location" {
  type        = string
  description = "Azure Government region for the deployment."
  default     = "usgovarizona"
}

variable "vnet_name" {
  type        = string
  description = "Existing virtual network name used by the high environment."
}

variable "vnet_resource_group_name" {
  type        = string
  description = "Optional resource group containing the existing virtual network."
  default     = null
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
