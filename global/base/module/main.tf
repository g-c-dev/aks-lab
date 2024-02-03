terraform {
  required_version = ">= 1.5.5"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0, >= 3.51.0"
    }
  }
}

variable "location" {
  type    = string
  default = "westeurope"
}

module "naming" {
  source  = "Azure/naming/azurerm"
  version = "0.4.0"
}

resource "azurerm_resource_group" "this" {
  name     = "global-${module.naming.resource_group.name_unique}"
  location = var.location
}

resource "azurerm_dns_zone" "this" {
  name                = "labs.g-c.dev"
  resource_group_name = azurerm_resource_group.this.name
}

output "global_hosted_zone" {
  value = azurerm_dns_zone.this.name
}

output "location" {
  value = azurerm_resource_group.this.location
}

output "global_resource_group_name" {
  value = azurerm_resource_group.this.name
}

