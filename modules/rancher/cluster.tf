resource "rancher2_cluster" "eks" {
  provider = rancher2.admin
  for_each = var.clusters

  name = each.value.name
  description = "Terraform EKS cluster - ${each.key}"
  eks_config_v2 {
    cloud_credential_id = rancher2_cloud_credential.manage_eks_permissions.id
    region = each.value.region
    kubernetes_version = each.value.kubernetes_version
    logging_types = []
    node_groups {
      name = each.value.name
      instance_type = "t3.medium"
      desired_size = 2
      max_size = 2
    }
    private_access = false
    public_access = true
    security_groups = each.value.securityGroups
    subnets = each.value.subnets
  }
}

resource "rancher2_app_v2" "eks" {
  provider = rancher2.admin
  for_each = var.clusters
  
  # cluster_id = rancher2_cluster.eks.id
  cluster_id = rancher2_cluster.eks[each.key].id
  name = "rancher-monitoring"
  namespace = "cattle-monitoring-system"
  repo_name = "rancher-charts"
  chart_name = "rancher-monitoring"
  chart_version = "100.1.2+up19.0.3"
  values = templatefile("${path.module}/monitoring_values.yaml", {})
}