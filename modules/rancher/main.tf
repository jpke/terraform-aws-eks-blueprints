resource "random_password" "rancher_admin_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*"
}

provider "rancher2" {
  alias = "bootstrap"

  api_url   = var.domain
  bootstrap = true
}

resource "rancher2_bootstrap" "admin" {
  provider = rancher2.bootstrap

  initial_password = var.bootstrapPassword
  password = random_password.rancher_admin_password.result
}

provider "rancher2" {
  alias = "admin"

  api_url = rancher2_bootstrap.admin.url
  token_key = rancher2_bootstrap.admin.token
}

resource "random_string" "random" {
  length           = 5
  special = false
}

resource "aws_secretsmanager_secret" "rancher_admin_password" {
  name = "${var.name}-${random_string.random.result}"

  tags = {
    purpose = "rancher admin secret"
  }
}

resource "aws_secretsmanager_secret_version" "rancher_admin_password" {
  secret_id     = aws_secretsmanager_secret.rancher_admin_password.id
  secret_string = random_password.rancher_admin_password.result
}