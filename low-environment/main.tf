data "azurerm_client_config" "current" {}

data "azurerm_resource_group" "target" {
  name = var.resource_group_name
}

locals {
  name_prefix         = lower(replace(var.prefix, "_", "-"))
  vnet_rg_name        = coalesce(var.vnet_resource_group_name, var.resource_group_name)
  unique_suffix       = substr(replace(data.azurerm_client_config.current.subscription_id, "-", ""), 0, 6)
  storage_name        = substr(replace(lower("${var.prefix}${local.unique_suffix}st"), "-", ""), 0, 24)
  registry_name       = substr(replace(lower("${var.prefix}${local.unique_suffix}acr"), "-", ""), 0, 50)
  aoai_name           = substr("${local.name_prefix}-aoai-${local.unique_suffix}", 0, 24)
  aoai_subdomain      = substr(replace(lower("${var.prefix}-${local.unique_suffix}-aoai"), "_", "-"), 0, 63)
  identity_name       = substr("${local.name_prefix}-storage-mi", 0, 24)
  private_dns_zone_rg = data.azurerm_resource_group.target.name
  common_tags = merge({
    environment = "low"
    managed-by  = "terraform"
  }, var.tags)
}

data "azurerm_virtual_network" "existing" {
  name                = var.vnet_name
  resource_group_name = local.vnet_rg_name
}

data "azurerm_subnet" "vm" {
  name                 = var.vm_subnet_name
  virtual_network_name = data.azurerm_virtual_network.existing.name
  resource_group_name  = local.vnet_rg_name
}

data "azurerm_subnet" "aoai" {
  name                 = var.aoai_subnet_name
  virtual_network_name = data.azurerm_virtual_network.existing.name
  resource_group_name  = local.vnet_rg_name
}

data "azurerm_subnet" "acr" {
  name                 = var.acr_subnet_name
  virtual_network_name = data.azurerm_virtual_network.existing.name
  resource_group_name  = local.vnet_rg_name
}

data "azurerm_subnet" "storage" {
  name                 = var.storage_subnet_name
  virtual_network_name = data.azurerm_virtual_network.existing.name
  resource_group_name  = local.vnet_rg_name
}

data "azurerm_subnet" "bastion" {
  count                = var.deploy_bastion ? 1 : 0
  name                 = var.bastion_subnet_name
  virtual_network_name = data.azurerm_virtual_network.existing.name
  resource_group_name  = local.vnet_rg_name
}

resource "azurerm_user_assigned_identity" "storage" {
  location            = var.location
  name                = local.identity_name
  resource_group_name = data.azurerm_resource_group.target.name
  tags                = local.common_tags
}

resource "azurerm_storage_account" "main" {
  name                            = local.storage_name
  resource_group_name             = data.azurerm_resource_group.target.name
  location                        = var.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  public_network_access_enabled   = false
  shared_access_key_enabled       = false
  allow_nested_items_to_be_public = false
  min_tls_version                 = "TLS1_2"
  tags                            = local.common_tags
}

resource "azurerm_role_assignment" "storage_identity" {
  scope                = azurerm_storage_account.main.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_user_assigned_identity.storage.principal_id
}

resource "azurerm_private_dns_zone" "storage" {
  name                = "privatelink.blob.core.usgovcloudapi.net"
  resource_group_name = local.private_dns_zone_rg
  tags                = local.common_tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "storage" {
  name                  = "${local.name_prefix}-storage-link"
  resource_group_name   = local.private_dns_zone_rg
  private_dns_zone_name = azurerm_private_dns_zone.storage.name
  virtual_network_id    = data.azurerm_virtual_network.existing.id
  registration_enabled  = false
  tags                  = local.common_tags
}

resource "azurerm_private_endpoint" "storage" {
  location            = var.location
  name                = "${local.name_prefix}-storage-pe"
  resource_group_name = data.azurerm_resource_group.target.name
  subnet_id           = data.azurerm_subnet.storage.id
  tags                = local.common_tags

  private_service_connection {
    is_manual_connection           = false
    name                           = "${local.name_prefix}-storage-psc"
    private_connection_resource_id = azurerm_storage_account.main.id
    subresource_names              = ["blob"]
  }

  private_dns_zone_group {
    name                 = "storage"
    private_dns_zone_ids = [azurerm_private_dns_zone.storage.id]
  }
}

resource "azurerm_container_registry" "main" {
  admin_enabled                 = false
  location                      = var.location
  name                          = local.registry_name
  public_network_access_enabled = false
  resource_group_name           = data.azurerm_resource_group.target.name
  sku                           = "Premium"
  tags                          = local.common_tags
}

resource "azurerm_private_dns_zone" "acr" {
  name                = "privatelink.azurecr.us"
  resource_group_name = local.private_dns_zone_rg
  tags                = local.common_tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "acr" {
  name                  = "${local.name_prefix}-acr-link"
  resource_group_name   = local.private_dns_zone_rg
  private_dns_zone_name = azurerm_private_dns_zone.acr.name
  virtual_network_id    = data.azurerm_virtual_network.existing.id
  registration_enabled  = false
  tags                  = local.common_tags
}

resource "azurerm_private_endpoint" "acr" {
  location            = var.location
  name                = "${local.name_prefix}-acr-pe"
  resource_group_name = data.azurerm_resource_group.target.name
  subnet_id           = data.azurerm_subnet.acr.id
  tags                = local.common_tags

  private_service_connection {
    is_manual_connection           = false
    name                           = "${local.name_prefix}-acr-psc"
    private_connection_resource_id = azurerm_container_registry.main.id
    subresource_names              = ["registry"]
  }

  private_dns_zone_group {
    name                 = "acr"
    private_dns_zone_ids = [azurerm_private_dns_zone.acr.id]
  }
}

resource "azurerm_cognitive_account" "aoai" {
  custom_subdomain_name         = local.aoai_subdomain
  kind                          = "OpenAI"
  location                      = var.location
  name                          = local.aoai_name
  public_network_access_enabled = false
  resource_group_name           = data.azurerm_resource_group.target.name
  sku_name                      = "S0"
  tags                          = local.common_tags
}

resource "azurerm_private_dns_zone" "aoai" {
  name                = "privatelink.openai.azure.us"
  resource_group_name = local.private_dns_zone_rg
  tags                = local.common_tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "aoai" {
  name                  = "${local.name_prefix}-aoai-link"
  resource_group_name   = local.private_dns_zone_rg
  private_dns_zone_name = azurerm_private_dns_zone.aoai.name
  virtual_network_id    = data.azurerm_virtual_network.existing.id
  registration_enabled  = false
  tags                  = local.common_tags
}

resource "azurerm_private_endpoint" "aoai" {
  location            = var.location
  name                = "${local.name_prefix}-aoai-pe"
  resource_group_name = data.azurerm_resource_group.target.name
  subnet_id           = data.azurerm_subnet.aoai.id
  tags                = local.common_tags

  private_service_connection {
    is_manual_connection           = false
    name                           = "${local.name_prefix}-aoai-psc"
    private_connection_resource_id = azurerm_cognitive_account.aoai.id
    subresource_names              = ["account"]
  }

  private_dns_zone_group {
    name                 = "aoai"
    private_dns_zone_ids = [azurerm_private_dns_zone.aoai.id]
  }
}

resource "azurerm_network_interface" "vm" {
  count               = var.vm_count
  location            = var.location
  name                = format("%s-vm%02d-nic", local.name_prefix, count.index + 1)
  resource_group_name = data.azurerm_resource_group.target.name
  tags                = local.common_tags

  ip_configuration {
    name                          = "internal"
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = data.azurerm_subnet.vm.id
  }
}

resource "azurerm_linux_virtual_machine" "vm" {
  count                           = var.vm_count
  admin_username                  = var.vm_admin_username
  disable_password_authentication = true
  location                        = var.location
  name                            = format("%s-vm%02d", local.name_prefix, count.index + 1)
  network_interface_ids           = [azurerm_network_interface.vm[count.index].id]
  resource_group_name             = data.azurerm_resource_group.target.name
  size                            = var.vm_size
  source_image_id                 = var.image_id
  tags                            = local.common_tags

  admin_ssh_key {
    public_key = var.vm_admin_ssh_public_key
    username   = var.vm_admin_username
  }

  identity {
    type = "SystemAssigned"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
}

resource "azurerm_role_assignment" "vm_storage" {
  count                = var.vm_count
  scope                = azurerm_storage_account.main.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_linux_virtual_machine.vm[count.index].identity[0].principal_id
}

resource "azurerm_public_ip" "bastion" {
  count               = var.deploy_bastion ? 1 : 0
  allocation_method   = "Static"
  location            = var.location
  name                = "${local.name_prefix}-bastion-pip"
  resource_group_name = data.azurerm_resource_group.target.name
  sku                 = "Standard"
  tags                = local.common_tags
}

resource "azurerm_bastion_host" "main" {
  count               = var.deploy_bastion ? 1 : 0
  location            = var.location
  name                = "${local.name_prefix}-bastion"
  resource_group_name = data.azurerm_resource_group.target.name
  tags                = local.common_tags

  ip_configuration {
    name                 = "configuration"
    public_ip_address_id = azurerm_public_ip.bastion[0].id
    subnet_id            = data.azurerm_subnet.bastion[0].id
  }
}
