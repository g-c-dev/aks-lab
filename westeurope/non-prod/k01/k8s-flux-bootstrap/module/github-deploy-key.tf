# create secret ssh key
resource "tls_private_key" "github_ssh" {
  algorithm = "ED25519"
}

resource "github_repository_deploy_key" "repository_deploy_key" {
  depends_on = [tls_private_key.github_ssh]
  title      = "flux-deployment-key"
  repository = var.github_repo_name
  key        = tls_private_key.github_ssh.public_key_openssh
  read_only  = "false"
}

resource "azurerm_key_vault_secret" "github_deploy_key" {
  depends_on   = [tls_private_key.github_ssh]
  name         = "ssh-deploy-key-private"
  value        = tls_private_key.github_ssh.private_key_openssh
  key_vault_id = var.key_vault_id
}

resource "azurerm_key_vault_secret" "github_deploy_key_pub" {
  depends_on   = [tls_private_key.github_ssh]
  name         = "identity-pub"
  value        = tls_private_key.github_ssh.public_key_openssh
  key_vault_id = var.key_vault_id
}


