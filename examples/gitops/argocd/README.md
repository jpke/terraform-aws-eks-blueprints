# Usage

## Create

```
terraform apply -target="module.vpc"
terraform apply -target="module.external_nlb"
terraform apply -target="module.eks_blueprints"
terraform apply -target="module.eks_blueprints_kubernetes_addons"
kubectl get secret --namespace argocd argocd-initial-admin-secret -o go-template='{{.data.password|base64decode}}{{"\n"}}'
terraform apply -target="module.rancher"
```

## Destroy

```
terraform destroy -target="module.rancher"

// remove workload from argocd_applications
terraform apply -target="module.eks_blueprints_kubernetes_addons"
// set argocd_applications = {}
terraform apply -target="module.eks_blueprints_kubernetes_addons"

terraform destroy -target="module.eks_blueprints_kubernetes_addons"
// remove rancher finalizer from namespaces
// kubectl patch ns argocd -p '{"metadata":{"finalizers":null}}' --type=merge
// kubectl patch ns argo-rollouts -p '{"metadata":{"finalizers":null}}' --type=merge
// kubectl patch ns aws-for-fluent-bit -p '{"metadata":{"finalizers":null}}' --type=merge
// kubectl patch ns cert-manager -p '{"metadata":{"finalizers":null}}' --type=merge
// kubectl patch ns ingress-nginx -p '{"metadata":{"finalizers":null}}' --type=merge

terraform destroy -target="module.eks_blueprints"
terraform destroy -target="module.external_nlb"
terraform destroy -target="module.vpc"
```

## Todo

```
Use terraform-generated random string for rancher bootstrap password
Provision cluster through rancher
Install monitoring in provisioned cluster via rancher
Install argocd via rancher
Install demo workload via rancher-installed argocd
Add custom grafana dashboard via argo

Stretch goals:
Leverage security groups for pods for external nlb
Install rancher via tf, instead of argocd
Install bansai logging operator via rancher
Install loki via argo
delete rancher finalizers in argocd namespaces, ingress-nginx namespace, cert-manager
```
