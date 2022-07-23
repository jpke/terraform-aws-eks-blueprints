provider "rancher2" {
  api_url   = var.domain
  bootstrap = true
}

data "kubernetes_secret" "bootstrap_secret" {
  metadata {
    name      = "bootstrap-secret"
    namespace = "cattle-system"
  }
  binary_data = {
    "bootstrapPassword" = ""
  }
}

# output "pw" {
#   value = data.kubernetes_secret.bootstrap_secret.data
# }
# output "pw_base64" {
#   value = data.kubernetes_secret.bootstrap_secret.binary_data
# }

resource "rancher2_bootstrap" "bootstrap_secret" {
  initial_password = data.kubernetes_secret.bootstrap_secret.data
  password = ""
}

# resource "rancher2_user" "foo" {
#   name = "Foouser"
#   username = "foo"
#   password = "changeme"
#   enabled = true
# }