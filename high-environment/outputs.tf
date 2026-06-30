output "acr_login_server" {
  value       = azurerm_container_registry.main.login_server
  description = "Private Azure Container Registry login server."
}

output "aoai_account_name" {
  value       = azurerm_cognitive_account.aoai.name
  description = "Azure OpenAI account name."
}

output "egress_nsg_id" {
  value       = azurerm_network_security_group.egress.id
  description = "NSG that denies outbound communication to the Internet."
}

output "storage_account_name" {
  value       = azurerm_storage_account.main.name
  description = "Storage account with shared keys disabled."
}

output "storage_managed_identity_id" {
  value       = azurerm_user_assigned_identity.storage.id
  description = "User-assigned identity granted Storage Blob Data Contributor."
}
