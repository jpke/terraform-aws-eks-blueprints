module "operator" {
  source        = "../helm-addon"
  helm_config   = local.helm_config
  irsa_config   = null
  addon_context = var.addon_context

  depends_on = [kubernetes_namespace_v1.prometheus]
}

resource "kubernetes_namespace_v1" "prometheus" {
  metadata {
    name = local.helm_config["namespace"]
  }
}
