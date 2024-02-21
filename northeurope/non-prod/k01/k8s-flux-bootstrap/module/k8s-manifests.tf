# create repository enrollment
resource "kubectl_manifest" "git_repo" {
  yaml_body = <<-YAML
  apiVersion: source.toolkit.fluxcd.io/v1
  kind: GitRepository
  metadata:
    name: k8s-config
    namespace: ${var.flux_namespace}
    labels:
      repo_slug: "${local.github_repo_slug}"
  spec:
    interval: ${var.repository_config.refresh}
    url: ${local.github_ssh_url}
    secretRef:
      name: ssh-deploy-key
    ref:
      branch: ${var.repository_config.reference}
YAML
}

# create flux kustomization
resource "kubectl_manifest" "helm_packages" {
  yaml_body = <<-YAML
  apiVersion: kustomize.toolkit.fluxcd.io/v1
  kind: Kustomization
  metadata:
    name: cluster-components
    namespace: "${var.flux_namespace}"
  spec:
    interval: "${var.repository_helm.refresh}"
    sourceRef:
      kind: GitRepository
      name: k8s-config
    path: "${var.repository_helm.path}"
    prune: true
    timeout: 10m
    wait: true
    postBuild:
      substituteFrom:
        - kind: ConfigMap
          name: flux-cluster-metadata
          # Use this ConfigMap if it exists, but proceed if it doesn't.
          optional: true
YAML
}

resource "kubectl_manifest" "helm_post_install" {
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
      name: k8s-config
    path: "${var.repository_config.path}"
    prune: true
    timeout: 10m
    dependsOn:
      - name: cluster-components
    postBuild:
      substituteFrom:
        - kind: ConfigMap
          name: flux-cluster-metadata
          # Use this ConfigMap if it exists, but proceed if it doesn't.
          optional: true
YAML
}

resource "kubectl_manifest" "tenants" {
  yaml_body = <<-YAML
  apiVersion: kustomize.toolkit.fluxcd.io/v1
  kind: Kustomization
  metadata:
    name: cluster-tenants
    namespace: "${var.flux_namespace}"
  spec:
    interval: "${var.repository_tenants.refresh}"
    sourceRef:
      kind: GitRepository
      name: k8s-config
    path: "${var.repository_tenants.path}"
    prune: true
    timeout: 10m
    dependsOn:
      - name: cluster-components
    postBuild:
      substituteFrom:
        - kind: ConfigMap
          name: flux-cluster-metadata
          # Use this ConfigMap if it exists, but proceed if it doesn't.
          optional: true
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
    known_hosts: ${base64encode(var.github_com_known_host)}
YAML
}

# cluster metadata for flux
resource "kubectl_manifest" "flux_cluster_metadata" {
  yaml_body = <<-YAML
  apiVersion: v1
  kind: ConfigMap
  metadata:
    name: flux-cluster-metadata
    namespace: "${var.flux_namespace}"
    annotations:
      replicator.v1.mittwald.de/replicate-to: "*"
  data: ${jsonencode(var.flux_cluster_metadata)}
YAML
}

# docker imagepullsecret
# .dockerconfigjson format
# {"auths":{"your.private.registry.example.com":{"username":"janedoe","password":"xxxxxxxxxxx","email":"jdoe@example.com","auth":"c3R...zE2"}}}
locals {
  dockerconfigjson = {
    "auths" = {
      "https://index.docker.io/v1/" = {
        "username" = var.docker_io_username
        "password" = var.docker_io_token
        "email"    = "jdoe@example.com"
        "auth"     = base64encode("${var.docker_io_username}:${var.docker_io_token}")
      }
    }
  }
}

resource "kubectl_manifest" "dockerio_imagepullsecret" {
  yaml_body = <<-YAML
  apiVersion: v1
  kind: Secret
  metadata:
    name: default
    namespace: "${var.flux_namespace}"
    annotations:
      # we enable if for synchronisation across namespaces
      kubed.appscode.com/sync: ""
      replicator.v1.mittwald.de/replicate-to: "*"
  data:
    .dockerconfigjson: ${base64encode(jsonencode(local.dockerconfigjson))}
  type: kubernetes.io/dockerconfigjson
YAML
}