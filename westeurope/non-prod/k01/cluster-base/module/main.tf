data "azurerm_client_config" "this" {}

module "naming" {
  source = "Azure/naming/azurerm"
}
