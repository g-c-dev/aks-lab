include "parent" {
  path   = find_in_parent_folders()
  expose = true
}

terraform {
  source = ".//module"
}

locals {
  kubelogin_args = [
    "get-token",
    "--environment",
    "AzurePublicCloud",
    "--server-id",
    "6dae42f8-4368-4678-94ff-3960e28e3630",
    "--login",
    "azurecli"
  ]
  fake_ca_cert = run_cmd("--terragrunt-quiet", "curl", "-s", "-o", "-", "https://raw.githubusercontent.com/richmoore/qt-examples/master/ssl-examples/add-custom-ca/cacert.pem")
}

dependency "cluster_aks" {
  config_path = "../cluster-aks/"

  mock_outputs = {
    host                   = "https://to-be-defined"
    cluster_ca_certificate = base64encode(local.fake_ca_cert)
  }
}


generate "providers" {
  path      = "_providers.module.tf"
  if_exists = "overwrite"
  contents  = <<-EOT
    provider "helm" {
      kubernetes {
        host                   = "${dependency.cluster_aks.outputs.host}"
        cluster_ca_certificate = ${jsonencode(base64decode(dependency.cluster_aks.outputs.cluster_ca_certificate))}

        exec {
          api_version = "client.authentication.k8s.io/v1beta1"
          args        = ${jsonencode(local.kubelogin_args)}
          command     = "kubelogin"
        }
      }
    }
EOT
}