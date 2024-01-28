variable "cluster_oidc_url" {
  type = string
}

variable "federated_identities" {
  type = list(object({
    name                         = string
    identity_resource_group_name = string
    identity_id                  = string
    service_account_namespace    = string
    service_account_name         = string
  }))
}