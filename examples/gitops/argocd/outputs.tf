output "worker_node_security_group_arn" {
  value = module.eks_blueprints.worker_node_security_group_id
}

output "configure_kubectl" {
  description = "Configure kubectl: make sure you're logged in with the correct AWS profile and run the following command to update your kubeconfig"
  value       = module.eks_blueprints.configure_kubectl
}

output "argocd_admin_password_secret" {
  description = "Retrieve argocd admin password secret"
  value = "kubectl get secret --namespace argocd argocd-initial-admin-secret -o go-template='{{.data.password|base64decode}}{{\"\n\"}}'"
}

output "rancher_admin_password_secret" {
  description = "Retrieve rancher admin password secret"
  value = module.rancher.rancher_admin_password_secret
}

output "rancher_user_password_secret" {
  description = "Retrieve rancher user password secret"
  value = module.rancher.rancher_user_password_secret
}