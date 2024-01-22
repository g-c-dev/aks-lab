variable "name_identifier" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "global_hosted_zone" {
  type = string
}

variable "global_resource_group_name" {
  type = string
}

data "azurerm_client_config" "this" {}

module "naming" {
  source = "Azure/naming/azurerm"
}

resource "azurerm_resource_group" "this" {
  location = var.location
  name     = var.resource_group_name
}

resource "azurerm_dns_zone" "this" {
  name                = "${var.name_identifier},${var.global_hosted_zone}"
  resource_group_name = azurerm_resource_group.this.name
}

resource "azurerm_user_assigned_identity" "dns" {
  location            = azurerm_resource_group.this.location
  name                = module.naming.user_assigned_identity.name_unique
  resource_group_name = azurerm_resource_group.this.name
}

resource "azurerm_dns_ns_record" "delegation" {
  name                = var.name_identifier
  records             = azurerm_dns_zone.this.name_servers
  resource_group_name = azurerm_resource_group.this.name
  ttl                 = 300
  zone_name           = var.global_hosted_zone
}

resource "azurerm_role_assignment" "dns" {
  principal_id = azurerm_user_assigned_identity.dns.principal_id
  # format -> /subscriptions/42cefed1-e79f-4f0d-828e-19ef5b9cd304/resourceGroups/rg-terraform-state
  scope        = "/subscriptions/${data.azurerm_client_config.this.subscription_id}/resourceGroups/${var.global_resource_group_name}"
}

output "resource_group_name" {
  value = azurerm_resource_group.this.name
}

output "location" {
  value = azurerm_resource_group.this.location
}

output "uai_dns_id" {
  value = azurerm_user_assigned_identity.dns.id
}
