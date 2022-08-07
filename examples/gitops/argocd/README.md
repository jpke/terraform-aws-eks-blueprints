# Usage

## Create

```
terraform apply -target="module.vpc"
terraform apply -target="module.external_nlb"
terraform apply -target="module.eks_blueprints"
terraform apply -target="module.eks_blueprints_kubernetes_addons"
kubectl get secret --namespace argocd argocd-initial-admin-secret -o go-template='{{.data.password|base64decode}}{{"\n"}}'
terraform apply -target="module.rancher"
// add admin role to rancher-created cluster https://docs.aws.amazon.com/eks/latest/userguide/add-user-role.html
```

## Destroy

```
// remove clusters created by rancher, then
terraform destroy -target="module.rancher"

//remove workload from argocd_applications, then
terraform apply -target="module.eks_blueprints_kubernetes_addons"
// set argocd_applications = {}, then
terraform apply -target="module.eks_blueprints_kubernetes_addons"

terraform destroy -target="module.eks_blueprints_kubernetes_addons"
// remove rancher finalizer from namespaces
./removeRancherFinalizers.sh

terraform destroy -target="module.eks_blueprints"
terraform destroy -target="module.external_nlb"
terraform destroy -target="module.vpc"
```

## Todo

```
Use terraform-generated random string for rancher bootstrap password

Stretch goals:
Leverage security groups for pods for external nlb
Install rancher via tf, instead of argocd
Install bansai logging operator via rancher
Install loki via argo
delete rancher finalizers in argocd namespaces, ingress-nginx namespace, cert-manager
Add custom grafana dashboard via argo
```
