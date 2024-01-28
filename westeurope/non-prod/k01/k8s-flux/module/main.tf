terraform {
  required_version = ">= 1.5.5"
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "2.12.1"
    }
  }
}

resource "helm_release" "flux" {
  chart            = "flux2"
  name             = "flux"
  version          = "2.12.2"
  repository       = "https://fluxcd-community.github.io/helm-charts"
  namespace        = var.flux_namespace
  create_namespace = true

}
