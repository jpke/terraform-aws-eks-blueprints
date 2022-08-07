output "rancher_admin_password_secret" {
  value = "aws secretsmanager get-secret-value --query SecretString --secret-id ${aws_secretsmanager_secret.rancher_admin_password.name}"
}

output "rancher_user_password_secret" {
  value = [for user in aws_secretsmanager_secret.rancher_user_password : "aws secretsmanager get-secret-value --query SecretString --secret-id ${user.name}"]
}