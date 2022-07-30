output "configure_kubectl" {
  description = "Configure kubectl: make sure you're logged in with the correct AWS profile and run the following command to update your kubeconfig"
  value       = module.eks_blueprints.configure_kubectl
}

output "rancher_admin_password_secret" {
  description = "Retrieve rancher admin password secret"
  value = module.rancher.rancher_admin_password_secret
}