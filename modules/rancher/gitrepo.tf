# # locals {
# #   cluster-gitrepo = flatten([
# #     for userKey, user in var.users : [
# #       for cluster in user.clusters : {
# #         user  = userKey
# #         cluster = cluster
# #       }
# #     ]
# #   ])
# # }

# locals {
#     gitrepos-clusternames = []
# }

# data "kubectl_file_documents" "gitrepo" {
#     for_each = var.gitrepos
#     content = templatefile("${path.module}/gitrepo.yaml", {
#       NAME = each.name
#       NAMESPACE = each.namespace
#       BRANCH = each.branch
#       PATHS = each.paths
#       REPO = each.repo
#       TARGETNAMESPACE = each.targetnamespace
#       CLUSTERNAME = each.clusters
#     })
# }

# resource "kubectl_manifest" "gitrepo" {
#     for_each  = data.kubectl_file_documents.docs.manifests
#     yaml_body = each.value
# }