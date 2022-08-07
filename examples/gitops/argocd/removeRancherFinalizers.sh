kubectl patch ns argocd -p '{"metadata":{"finalizers":null}}' --type=merge
kubectl patch ns argo-rollouts -p '{"metadata":{"finalizers":null}}' --type=merge
kubectl patch ns aws-for-fluent-bit -p '{"metadata":{"finalizers":null}}' --type=merge
kubectl patch ns cert-manager -p '{"metadata":{"finalizers":null}}' --type=merge
kubectl patch ns ingress-nginx -p '{"metadata":{"finalizers":null}}' --type=merge