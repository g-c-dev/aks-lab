resource "azurerm_dns_zone" "this" {
  name                = "${var.name_identifier}.${var.global_hosted_zone}"
  resource_group_name = var.resource_group_name
}

resource "azurerm_user_assigned_identity" "dns" {
  location            = var.location
  name                = module.naming.user_assigned_identity.name_unique
  resource_group_name = var.resource_group_name
}

resource "azurerm_dns_ns_record" "delegation" {
  name                = var.name_identifier
  records             = azurerm_dns_zone.this.name_servers
  resource_group_name = var.global_resource_group_name
  zone_name           = var.global_hosted_zone
  ttl                 = 300
}

resource "azurerm_role_assignment" "dns" {
  principal_id = azurerm_user_assigned_identity.dns.principal_id
  # format -> /subscriptions/42cefed1-e79f-4f0d-828e-19ef5b9cd304/resourceGroups/rg-terraform-state
  scope                = "/subscriptions/${data.azurerm_client_config.this.subscription_id}/resourceGroups/${var.global_resource_group_name}"
  role_definition_name = "DNS Zone Contributor"
}
