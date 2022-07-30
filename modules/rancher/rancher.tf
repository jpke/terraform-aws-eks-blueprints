# https://github.com/rancher/quickstart/blob/master/rancher/rancher-common/helm.tf

resource "helm_release" "rancher_server" {
  count = var.installRancher == true ? 1 : 0
  name             = "rancher"
  chart            = "https://releases.rancher.com/server-charts/latest/rancher-${var.rancher_version}.tgz"
  namespace        = "cattle-system"
  create_namespace = true
  wait             = true

  set {
    name  = "hostname"
    value = var.domain
  }

  set {
    name  = "replicas"
    value = "1"
  }

  set {
    name  = "bootstrapPassword"
    value = var.bootstrapPassword # TODO: change this once the terraform provider has been updated with the new pw bootstrap logic
  }
}