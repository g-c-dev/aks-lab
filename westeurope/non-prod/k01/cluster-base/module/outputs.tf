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

output "uai_dns_id" {
  value = azurerm_user_assigned_identity.dns.id
}

