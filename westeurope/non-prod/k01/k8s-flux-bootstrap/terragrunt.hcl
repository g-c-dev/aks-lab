include "parent" {
  path   = find_in_parent_folders()
  expose = true
}

terraform {
  source = ".//module"
}

locals {
  github_pat         = get_env("GITHUB_TOKEN", "none")
  github_repo_owner  = get_env("GITHUB_OWNER", "g-c-dev")
  github_repo_name   = get_env("GITHUB_REPOSITORY", "aks-lab-gitops")
  docker_io_username = get_env("DOCKERIO_USER", "gchiesa")
  docker_io_token    = get_env("DOCKERIO_TOKEN")
  kubelogin_args     = [
    "get-token",
    "--environment",
    "AzurePublicCloud",
    "--server-id",
    "6dae42f8-4368-4678-94ff-3960e28e3630",
    "--login",
    "azurecli"
  ]
}

dependency "cluster_base" {
  config_path  = "../cluster-base"
  mock_outputs = {
    key_vault_id        = "/subscriptions/12345678-1234-9876-4563-123456789012/resourceGroups/example-resource-group/providers/Microsoft.KeyVault/vaults/vaultValue"
    uai_dns_client_id   = "to-be-defined"
    resource_group_name = "to-be-defined"
    tenant_id           = "to-be-defined"
    subscription_id     = "to-be-defined"
    clusterFQDN         = "to-be-defined"
  }
}

dependency "cluster_aks" {
  config_path = "../cluster-aks/"

  mock_outputs = {
    host                   = "https://to-be-defined"
    cluster_ca_certificate = base64encode("to-be-defined")
  }
}

dependency "k8s_flux" {
  config_path  = "../k8s-flux"
  skip_outputs = true
}

inputs = {
  aks_host              = dependency.cluster_aks.outputs.host
  aks_ca_certificate    = dependency.cluster_aks.outputs.cluster_ca_certificate
  github_repo_owner     = local.github_repo_owner
  github_repo_name      = local.github_repo_name
  docker_io_username    = local.docker_io_username
  docker_io_token       = local.docker_io_token
  key_vault_id          = dependency.cluster_base.outputs.key_vault_id
  flux_cluster_metadata = {
    "dnsManagementClientId"           = dependency.cluster_base.outputs.uai_dns_client_id
    "dnsManagementAzureResourceGroup" = dependency.cluster_base.outputs.resource_group_name
    "azureTenantId"                   = dependency.cluster_base.outputs.tenant_id
    "azureSubscriptionId"             = dependency.cluster_base.outputs.subscription_id
    "clusterFQDN"                     = dependency.cluster_base.outputs.clusterFQDN
  }
}

generate "providers" {
  path      = "_providers.module.tf"
  if_exists = "overwrite"
  contents  = <<-EOT
    provider "kubectl" {
      host                   = "${dependency.cluster_aks.outputs.host}"
      cluster_ca_certificate = ${jsonencode(base64decode(dependency.cluster_aks.outputs.cluster_ca_certificate))}

      exec {
        api_version = "client.authentication.k8s.io/v1beta1"
        args        = ${jsonencode(local.kubelogin_args)}
        command     = "kubelogin"
      }
    }
    provider "github" {
      owner = "${local.github_repo_owner}"
      token = "${local.github_pat}"
    }
    provider "tls" {
    }
EOT
}
