resource "random_password" "rancher_bootstrap_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*"
}

resource "random_string" "random" {
  length           = 5
  special = false
}

resource "aws_secretsmanager_secret" "rancher_bootstrap_password" {
  name = "${local.name}-rancher-bootstrap-${random_string.random.result}"

  tags = {
    purpose = "rancher bootstrap secret"
  }
}

resource "aws_secretsmanager_secret_version" "rancher_bootstrap_password" {
  secret_id     = aws_secretsmanager_secret.rancher_bootstrap_password.id
  secret_string = random_password.rancher_bootstrap_password.result
}