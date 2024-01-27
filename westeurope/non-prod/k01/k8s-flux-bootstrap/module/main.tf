terraform {
  required_version = ">= 1.5.5"
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.25.2"
    }
    github = {
      source  = "integrations/github"
      version = "6.0.0-beta"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "4.0.5"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0, >= 3.51.0"
    }
    kubectl = {
      source  = "alekc/kubectl"
      version = "~> 2.0"
    }
  }
}

locals {
  github_http_url  = "https://github.com/${var.github_repo_owner}/${var.github_repo_name}"
  github_ssh_url   = "ssh://git@github.com/${var.github_repo_owner}/${var.github_repo_name}"
  github_repo_slug = "${var.github_repo_owner}-${var.github_repo_name}"
}