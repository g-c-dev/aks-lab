variable "github_repo_owner" {
  type = string
}

variable "github_repo_name" {
  type = string
}

variable "key_vault_id" {
  type = string
}

variable "flux_namespace" {
  type    = string
  default = "flux-system"
}

variable "repository_config" {
  type = object({
    refresh   = string
    reference = string
    path      = string
  })
  default = {
    refresh   = "3m"
    reference = "main"
    path      = "cluster-config"
  }
}

variable "github_com_known_host" {
  type    = string
  default = "github.com ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBEmKSENjQEezOmxkZMy7opKgwFB9nkt5YRrYMjNuG5N87uRgg6CLrbo5wAdT/y6v0mKV0U2w0WZ2YB/++Tpockg="
}