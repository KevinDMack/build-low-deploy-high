output "acr_login_server" {
  value       = azurerm_container_registry.main.login_server
  description = "Private Azure Container Registry login server."
}

output "aoai_account_name" {
  value       = azurerm_cognitive_account.aoai.name
  description = "Azure OpenAI account name."
}

output "storage_account_name" {
  value       = azurerm_storage_account.main.name
  description = "Storage account with shared keys disabled."
}

output "storage_managed_identity_id" {
  value       = azurerm_user_assigned_identity.storage.id
  description = "User-assigned identity granted Storage Blob Data Contributor."
}

output "vm_ids" {
  value       = azurerm_linux_virtual_machine.vm[*].id
  description = "IDs of the low environment virtual machines."
}
