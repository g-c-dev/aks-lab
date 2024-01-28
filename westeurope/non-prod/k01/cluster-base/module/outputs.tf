output "tenant_id" {
  value = data.azurerm_client_config.this.tenant_id
}

output "subscription_id" {
  value = data.azurerm_client_config.this.subscription_id
}

output "resource_group_name" {
  value = var.resource_group_name
}

output "key_vault_name" {
  value = azurerm_key_vault.this.name
}

output "key_vault_id" {
  value = azurerm_key_vault.this.id
}

output "location" {
  value = var.location
}

output "uai_dns_client_id" {
  value = azurerm_user_assigned_identity.dns.client_id
}

output "uai_dns_name" {
  value = azurerm_user_assigned_identity.dns.name
}

output "uai_dns_id" {
  value = azurerm_user_assigned_identity.dns.id
}

