resource "random_password" "rancher_user_password" {
  for_each = var.users

  length           = 16
  special          = true
  override_special = "!#$%&*"
}

resource "rancher2_user" "users" {
  provider = rancher2.admin
  for_each = var.users
  
  name = each.key
  username = each.key
  password = random_password.rancher_user_password[each.key].result
  enabled = true
}

resource "aws_secretsmanager_secret" "rancher_user_password" {
  for_each = var.users

  name = "${each.key}-${random_string.random.result}"
  tags = {
    purpose = "rancher user ${each.key} secret"
  }
}

resource "aws_secretsmanager_secret_version" "rancher_user_password" {
  for_each = var.users

  secret_id     = aws_secretsmanager_secret.rancher_user_password[each.key].id
  secret_string = random_password.rancher_user_password[each.key].result
}

locals {
  user-cluster = flatten([
    for userKey, user in var.users : [
      for cluster in user.clusters : {
        user  = userKey
        cluster = cluster
      }
    ]
  ])
}

resource "rancher2_cluster_role_template_binding" "user" {
  provider = rancher2.admin
  for_each = {
    for uc in local.user-cluster : "${uc.user}-${uc.cluster}" => uc
  }

  name = "${each.value.user}-${each.value.cluster}"
  cluster_id = rancher2_cluster.eks[each.value.cluster].id
  role_template_id = "cluster-member"
  user_id = rancher2_user.users[each.value.user].id
}