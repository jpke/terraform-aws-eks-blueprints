output "rancher_admin_password_secret" {
  value = "aws secretsmanager get-secret-value --query SecretString --secret-id ${aws_secretsmanager_secret.rancher_admin_password.name}"
}