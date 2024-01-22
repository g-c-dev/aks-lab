terraform {
  source = ".//module"

  before_hook "allocate_state_storage" {
    commands = [ "init", "apply", "plan" ]
    execute  = [
      "bash",
      "${get_repo_root()}/hack/ensure_remote_state.sh",
      "global-resources"
    ]
  }
}

generate "backend" {
  path      = "_backend.tf"
  if_exists = "overwrite"
  contents  = <<-EOT
      terraform {
        backend "azurerm" {
          resource_group_name  = "rg-terraform-state"
          storage_account_name = "saterraformstate42cefed1"
          container_name       = "global-resources"
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