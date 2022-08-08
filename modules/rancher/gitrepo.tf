locals {
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

resource "kubectl_manifest" "gitrepo" {
    for_each = local.gitrepos_with_cluster_ids

    yaml_body = templatefile("${path.module}/gitrepo.tftpl", {
      name = each.value.name
      namespace = each.value.namespace
      branch = each.value.branch
      paths = each.value.paths
      repo = each.value.repo
      targetNamespace = each.value.targetNamespace
      clusters = [ for cluster in each.value.clusters : rancher2_cluster.eks[cluster].id ]
    })
}