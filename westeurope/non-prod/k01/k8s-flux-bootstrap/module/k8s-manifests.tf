# create repository enrollment
resource "kubectl_manifest" "git_repo" {
  yaml_body = <<-YAML
  apiVersion: source.toolkit.fluxcd.io/v1
  kind: GitRepository
  metadata:
    name: ${local.github_repo_slug}
    namespace: ${var.flux_namespace}
  spec:
    interval: ${var.repository_config.refresh}
    url: ${local.github_ssh_url}
    secretRef:
      name: cluster-config
    ref:
      branch: ${var.repository_config.reference}
YAML
}

# create flux kustomization
resource "kubectl_manifest" "kustomization" {
  yaml_body = <<-YAML
  apiVersion: kustomize.toolkit.fluxcd.io/v1
  kind: Kustomization
  metadata:
    name: cluster-configuration
    namespace: "${var.flux_namespace}"
  spec:
    interval: "${var.repository_config.refresh}"
    sourceRef:
      kind: GitRepository
      name: "${local.github_repo_slug}"
    path: "${var.repository_config.path}"
    prune: true
    timeout: 1m
YAML
}

# ssh deploy key
resource "kubectl_manifest" "git_secret" {
  yaml_body = <<-YAML
  apiVersion: v1
  kind: Secret
  metadata:
    name: ssh-deploy-key
    namespace: "${var.flux_namespace}"
  data:
    identity: ${base64encode(tostring(azurerm_key_vault_secret.github_deploy_key.value))}
    identity.pub: ${base64encode(tostring(azurerm_key_vault_secret.github_deploy_key_pub.value))}
    known-hosts: ${base64encode(var.github_com_known_host)}
YAML
}
