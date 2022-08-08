# locals {
#   cluster-gitrepo = flatten([
#     for userKey, user in var.users : [
#       for cluster in user.clusters : {
#         user  = userKey
#         cluster = cluster
#       }
#     ]
#   ])
# }

  # gitrepos = {
  #   helm = {
  #     namespace = "fleet-default"
  #     branch = "downstream"
  #     paths = [
  #       "single-cluster/helm"
  #     ]
  #     repo = "https://github.com/jpke/fleet-examples.git"
  #     targetNamespace = ""
  #     clusters = [
  #       "one"
  #     ]
  #   }
  # }

locals {
    # gitrepo_per_cluster = flatten([
    #   for grKey grValue in var.gitrepos : [
    #     for cluster in grValue.clusters : {
    #       gitrepo = grKey
    #       cluster = cluster
    #       namespace = grValue.namespace
    #       branch = grValue.branch
    #       paths = grValue.paths
    #       repo = grValue.repo
    #       targetNamespace = grValue.targetNamespace
    #     }
    #   ]
    # ])

    # gitrepo-clusternames = {
    #   for gc in local.gitrepo_per_cluster : "${gc.gitrepo}-${gc.cluster}" => gc
    # }

    gitrepos_with_cluster_ids = {
      for gitrepoName, gitrepo in var.gitrepos : gitrepoName =>  {
        name = gitrepoName
        clusters = gitrepo.clusters
        namespace = gitrepo.namespace
        branch = gitrepo.branch
        paths = gitrepo.paths
        repo = gitrepo.repo
        targetNamespace = gitrepo.targetNamespace
      }
    }
}

# resource "kubernetes_manifest" "gitrepo" {
#   for_each = local.gitrepos_with_cluster_ids

#   manifest = yamldecode(yamlencode({
#     "apiVersion": "fleet.cattle.io/v1alpha1"
#     "kind": "GitRepo"
#     "metadata": {
#       "name": each.value.name
#       "namespace": each.value.namespace
#     }
#     "spec": {
#       "branch": each.value.branch
#       "paths": [ for path in each.value.paths : "${path}"]
#       "repo": each.value.repo
#       "targetNamespace": each.value.targetNamespace
#       "targets": [ for cluster in each.value.clusters : "clusterName: ${rancher2_cluster.eks[cluster].id}"]
#     }
#   }))
# }

data "kubectl_file_documents" "gitrepo" {
    for_each = local.gitrepos_with_cluster_ids
    content = templatefile("${path.module}/gitrepo.tftpl", {
      name = each.value.name
      namespace = each.value.namespace
      branch = each.value.branch
      paths = each.value.paths
      repo = each.value.repo
      targetNamespace = each.value.targetNamespace
      clusters = each.value.clusters
    })
}

resource "kubectl_manifest" "gitrepo" {
  for_each = data.kubectl_file_documents.gitrepo

  yaml_body = each.value.documents
 
#   yaml_body = yamlencode({
# "apiVersion": "fleet.cattle.io/v1alpha1"
# "kind": "GitRepo"
# "metadata": {
#   "name": each.value.name
#   "namespace": each.value.namespace
# }
# "spec": {
#   "branch": each.value.branch
#   "paths": [ for path in each.value.paths : "${path}"]
#   "repo": each.value.repo
#   "targetNamespace": each.value.targetNamespace
#   "targets": [ for cluster in each.value.clusters : "clusterName: ${rancher2_cluster.eks[cluster].id}"]
#     }
#   })
}

# resource "kubectl_manifest" "test" {
#     yaml_body = <<YAML
# apiVersion: networking.k8s.io/v1
# kind: Ingress
# metadata:
#   name: test-ingress
#   annotations:
#     nginx.ingress.kubernetes.io/rewrite-target: /
#     azure/frontdoor: enabled
# spec:
#   rules:
#   - http:
#       paths:
#       - path: /testpath
#         pathType: "Prefix"
#         backend:
#           serviceName: test
#           servicePort: 80
# YAML
# }