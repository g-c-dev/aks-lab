include "parent" {
  path   = find_in_parent_folders()
  expose = true
}

terraform {
  source = ".//module"

  before_hook "allocate_rg_because_of_aks" {
    commands = [ "apply", "plan" ]

    execute = [
      "az", "group", "create",
      "--name", "${include.parent.inputs.resource_group_name}",
      "--location", "${dependency.global_resource.outputs.location}",
    ]
  }

}

dependency "global_resource" {
  config_path = "${get_repo_root()}/global/base/"

  mock_outputs = {
    location                   = "northeurope"
    global_hosted_zone         = "to-be-defined"
    global_resource_group_name = "to-be-defined"
  }
}

inputs = {
  name_identifier            = include.parent.inputs.cluster_name
  resource_group_name        = include.parent.inputs.resource_group_name
  location                   = dependency.global_resource.outputs.location
  global_hosted_zone         = dependency.global_resource.outputs.global_hosted_zone
  global_resource_group_name = dependency.global_resource.outputs.global_resource_group_name
}

