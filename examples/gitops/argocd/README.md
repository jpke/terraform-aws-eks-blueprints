# Usage

## Create

terraform apply -target="module.vpc"
terraform apply -target="module.external_nlb"
terraform apply -target="module.eks_blueprints"
terraform apply -target="module.eks_blueprints_kubernetes_addons"

## Destroy

terraform destroy -target="module.eks_blueprints_kubernetes_addons"
terraform destroy -target="module.eks_blueprints"
terraform destroy -target="module.external_nlb"
terraform destroy -target="module.vpc"
