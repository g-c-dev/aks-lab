include "parent" {
  path   = find_in_parent_folders()
  expose = true
}

terraform {
  source = "tfr://registry.terraform.io/Azure/aks/azurerm?version=7.5.0"
}

dependency "cluster_base" {
  config_path  = "../cluster-base"
  mock_outputs = {
    resource_group_name = include.parent.inputs.resource_group_name
    location            = "westeurope"
  }
}

dependency "cluster_network" {
  config_path  = "../cluster-network"
  mock_outputs = {
    vnet_subnets_name_id = {
      "snet-cluster-network" = "/subscriptions/12345678-1234-9876-4563-123456789012/resourceGroups/example-resource-group/providers/Microsoft.Network/virtualNetworks/virtualNetworksValue/subnets/subnetValue"
    }
  }
}

inputs = {
  resource_group_name = dependency.cluster_base.outputs.resource_group_name
  location            = dependency.cluster_base.outputs.location
  cluster_name        = include.parent.inputs.cluster_name
  vnet_subnet_id      = lookup(dependency.cluster_network.outputs.vnet_subnets_name_id, "snet-cluster-network")

  prefix = include.parent.inputs.cluster_name

  kubernetes_version   = "1.27.7"
  orchestrator_version = "1.27.7"

  network_plugin = "azure"
  network_policy = "azure"

  rbac_aad                          = true
  rbac_aad_azure_rbac_enabled       = true
  role_based_access_control_enabled = true

  temporary_name_for_rotation = "rotating"

  oidc_issuer_enabled             = true
  log_analytics_workspace_enabled = false
  workload_identity_enabled       = true
  enable_auto_scaling             = true
  enable_host_encryption          = true
  image_cleaner_enabled           = true
}