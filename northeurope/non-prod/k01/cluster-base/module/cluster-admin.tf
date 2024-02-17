resource "azurerm_role_assignment" "cluster_admin" {
  principal_id         = data.azurerm_client_config.this.object_id
  scope                = "/subscriptions/${data.azurerm_client_config.this.subscription_id}/resourceGroups/${var.resource_group_name}"
  role_definition_name = "Azure Kubernetes Service RBAC Cluster Admin"
}