# Usage

## Create

```
terraform apply -target="module.vpc"
terraform apply -target="module.external_nlb"
terraform apply -target="module.eks_blueprints"
terraform apply -target="module.eks_blueprints_kubernetes_addons"
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
terraform destroy -target="module.eks_blueprints"
terraform destroy -target="module.external_nlb"
terraform destroy -target="module.vpc"
```

## Todo

```
Install rancher via tf, instead of argocd
Initialize rancher via terraform bootstrap
Provision cluster through rancher
Install monitoring in provisioned cluster via rancher
Install argocd via rancher
Install demo workload via rancher-installed argocd
Add custom grafana dashboard via argo

Stretch goals:
Install bansai logging operator via rancher
Install loki via argo
delete rancher finalizers in argocd namespaces, ingress-nginx namespace, cert-manager
```
