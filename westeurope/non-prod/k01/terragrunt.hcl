locals {
  cluster_name         = basename(get_parent_terragrunt_dir())
  state_file_container = "non-prod-westeurope-${basename(get_terragrunt_dir())}"
  resource_group_name  = "rg-${local.cluster_name}"
}

terraform {
  before_hook "allocate_state_storage" {
    commands = [ "init", "apply", "plan" ]
    execute  = [
      "bash",
      "${get_repo_root()}/hack/ensure_remote_state.sh",
      "${local.state_file_container}"
    ]
  }
}

inputs = {
  cluster_name        = local.cluster_name
  resource_group_name = local.resource_group_name
}

generate "backend" {
  path      = "_backend.tf"
  if_exists = "overwrite"
  contents  = <<-EOT
      terraform {
        backend "azurerm" {
          resource_group_name  = "rg-terraform-state"
          storage_account_name = "saterraformstate42cefed1"
          container_name       = "${local.state_file_container}"
          key                  = "${path_relative_to_include()}/terraform.tfstate"
        }
      }
EOT
}

generate "providers" {
  path      = "_providers.tf"
  if_exists = "overwrite"
  contents  = <<-EOT
    provider "azurerm" {
      features {
        resource_group {
          prevent_deletion_if_contains_resources = false
        }
      }
    }
EOT
}