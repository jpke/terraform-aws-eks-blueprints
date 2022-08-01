output "configure_kubectl" {
  description = "Configure kubectl: make sure you're logged in with the correct AWS profile and run the following command to update your kubeconfig"
  value       = module.eks_blueprints.configure_kubectl
}

output "argocd_admin_password_secret" {
  description = "Retrieve argocd admin password secret"
  # value = "kubectl get secret --namespace argocd argocd-initial-admin-secret -o go-template='{{.data.password|base64decode}}{{\"\n\"}}'"
  value = "test output"
}

output "rancher_admin_password_secret" {
  description = "Retrieve rancher admin password secret"
  value = module.rancher.rancher_admin_password_secret
}