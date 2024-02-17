resource "azurerm_key_vault" "this" {
  location                   = var.location
  name                       = module.naming.key_vault.name_unique
  resource_group_name        = var.resource_group_name
  sku_name                   = "standard"
  tenant_id                  = data.azurerm_client_config.this.tenant_id
  soft_delete_retention_days = 7
  purge_protection_enabled   = false
  enable_rbac_authorization  = true
}

resource "azurerm_role_assignment" "deployer_vault" {
  principal_id         = data.azurerm_client_config.this.object_id
  scope                = azurerm_key_vault.this.id
  role_definition_name = "Key Vault Secrets Officer"
}
