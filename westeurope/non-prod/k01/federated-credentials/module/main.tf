terraform {
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0, >= 3.51.0"
    }
  }
}

resource "random_string" "this" {
  length  = 4
  upper   = false
  special = false
}

resource "azurerm_federated_identity_credential" "federated_identity_credentials" {
  for_each = { for fi in var.federated_identities : fi["name"] => fi }

  name                = "fedcred-${each.value["name"]}-${random_string.this.result}"
  resource_group_name = each.value["identity_resource_group_name"]
  audience            = ["api://AzureADTokenExchange"]
  issuer              = var.cluster_oidc_url
  parent_id           = each.value["identity_id"]
  subject             = "system:serviceaccount:${each.value["service_account_namespace"]}:${each.value["service_account_name"]}"
}
