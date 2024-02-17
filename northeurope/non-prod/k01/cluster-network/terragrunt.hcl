include "parent" {
  path   = find_in_parent_folders()
  expose = true
}

terraform {
  source = "tfr://registry.terraform.io/Azure/vnet/azurerm?version=4.1.0"
}

dependency "cluster_base" {
  config_path  = "../cluster-base"
  mock_outputs = {
    resource_group_name = "to-be-defined"
    location            = "northeurope"
  }
}

inputs = {
  resource_group_name = dependency.cluster_base.outputs.resource_group_name
  vnet_location       = dependency.cluster_base.outputs.location
  use_for_each        = true
  vnet_name           = "vnet-${include.parent.inputs.cluster_name}"
  subnet_names        = [ "snet-cluster-network" ]
  subnet_prefixes     = [ "10.0.1.0/24" ]
}