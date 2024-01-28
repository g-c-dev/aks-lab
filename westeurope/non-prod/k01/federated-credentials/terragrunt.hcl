include "parent" {
  path   = find_in_parent_folders()
  expose = true
}

terraform {
  source = ".//module"
}

dependency "cluster_base" {
  config_path  = "../cluster-base"
  mock_outputs = {
    uai_dns_id          = "to-be-defined"
    resource_group_name = "to-be-defined"
  }
}

dependency "cluster_aks" {
  config_path = "../cluster-aks/"

  mock_outputs = {
    oidc_issuer_url = "https://to-be-defined"
  }
}

inputs = {
  cluster_oidc_url     = dependency.cluster_aks.outputs.oidc_issuer_url
  federated_identities = [
    {
      name                         = "cert-manager"
      identity_resource_group_name = dependency.cluster_base.outputs.resource_group_name
      identity_id                  = dependency.cluster_base.outputs.uai_dns_id
      service_account_namespace    = "cert-manager"
      service_account_name         = "cert-manager"
    },
    {
      name                         = "external-dns"
      identity_resource_group_name = dependency.cluster_base.outputs.resource_group_name
      identity_id                  = dependency.cluster_base.outputs.uai_dns_id
      service_account_namespace    = "external-dns"
      service_account_name         = "external-dns"
    }
  ]
}

generate "providers" {
  path      = "_providers.module.tf"
  if_exists = "overwrite"
  contents  = <<-EOT
    provider "random" {
      # Configuration options
    }
EOT
}
