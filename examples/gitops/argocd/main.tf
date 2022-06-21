provider "aws" {
  region = local.region
}

provider "kubernetes" {
  host                   = module.eks_blueprints.eks_cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks_blueprints.eks_cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1alpha1"
    command     = "aws"
    # This requires the awscli to be installed locally where Terraform is executed
    args = ["eks", "get-token", "--cluster-name", module.eks_blueprints.eks_cluster_id]
  }
}

provider "helm" {
  kubernetes {
    host                   = module.eks_blueprints.eks_cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks_blueprints.eks_cluster_certificate_authority_data)

    exec {
      api_version = "client.authentication.k8s.io/v1alpha1"
      command     = "aws"
      # This requires the awscli to be installed locally where Terraform is executed
      args = ["eks", "get-token", "--cluster-name", module.eks_blueprints.eks_cluster_id]
    }
  }
}

data "aws_availability_zones" "available" {}

locals {
  name   = basename(path.cwd)
  region = "us-east-1"

  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)

  tags = {
    Blueprint  = local.name
    GithubRepo = "github.com/aws-ia/terraform-aws-eks-blueprints"
  }
}

resource "aws_security_group" "nginx_ingress" {
  name        = "allow_nginx_ingress"
  description = "Allow TCP inbound traffic"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "Allow http ingress to nginx http nodeports from public subnets and internet"
    protocol    = "TCP"
    from_port   = 32063
    to_port     = 32063
    cidr_blocks      = concat(["0.0.0.0/0"], [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k)])
  }

  ingress {
    description = "Allow http ingress to nginx http nodeports from public subnets and internet"
    protocol    = "TCP"
    from_port   = 32234
    to_port     = 32234
    cidr_blocks      = concat(["0.0.0.0/0"], [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k)])
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_nginx_ingress"
  }
}

#---------------------------------------------------------------
# EKS Blueprints
#---------------------------------------------------------------
module "eks_blueprints" {
  source = "../../.."

  cluster_name    = local.name
  cluster_version = "1.21"

  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnets

  managed_node_groups = {
    mg_5 = {
      node_group_name = "managed-ondemand"
      instance_types  = ["m5.large"]
      subnet_ids      = module.vpc.private_subnets

      desired_size = 2
      max_size     = 10
      min_size     = 2
    }
  }

  # node_security_group_additional_rules = {
  #   nginx_http_ingress = {
  #     description = "Allow http ingress to nginx http nodeports from public subnets and internet"
  #     protocol    = "TCP"
  #     from_port   = 32063
  #     to_port     = 32063
  #     type        = "ingress"
  #     cidr_blocks      = concat(["0.0.0.0/0"], [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k)])
  #   }
  #   nginx_https_ingress = {
  #     description = "Allow ingress to nginx https nodeports from public subnets and internet"
  #     protocol    = "TCP"
  #     from_port   = 32234
  #     to_port     = 32234
  #     type        = "ingress"
  #     cidr_blocks      = concat(["0.0.0.0/0"], [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k)])
  #   }
  # }

  tags = local.tags
}

module "eks_blueprints_kubernetes_addons" {
  source = "../../../modules/kubernetes-addons"

  eks_cluster_id = module.eks_blueprints.eks_cluster_id

  enable_argocd = true
  argocd_helm_config = {
    values = [templatefile("${path.module}/argocd_values.yaml", {})]
  }
  argocd_manage_add_ons = true # Indicates that ArgoCD is responsible for managing/deploying add-ons
  argocd_applications = {
    addons = {
      path               = "chart"
      repo_url           = "https://github.com/jpke/eks-blueprints-add-ons.git"
      add_on_application = true
    }
    workloads = {
      path               = "envs/dev"
      repo_url           = "https://github.com/jpke/eks-blueprints-workloads.git"
      add_on_application = false
    }
  }

  # EKS Managed Add-ons
  enable_amazon_eks_coredns    = true
  enable_amazon_eks_kube_proxy = true

  # Add-ons
  enable_aws_for_fluentbit            = true
  enable_aws_load_balancer_controller = true
  enable_cert_manager                 = true
  enable_cluster_autoscaler           = true
  enable_metrics_server               = true
  enable_argo_rollouts                = true
  enable_ingress_nginx                = true

  tags = local.tags

  depends_on = [module.eks_blueprints.managed_node_groups, module.vpc]
}

#---------------------------------------------------------------
# Supporting Resources
#---------------------------------------------------------------
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0"

  name = local.name
  cidr = local.vpc_cidr

  azs             = local.azs
  public_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k)]
  private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 10)]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  # Manage so we can name
  manage_default_network_acl    = true
  default_network_acl_tags      = { Name = "${local.name}-default" }
  manage_default_route_table    = true
  default_route_table_tags      = { Name = "${local.name}-default" }
  manage_default_security_group = true
  default_security_group_tags   = { Name = "${local.name}-default" }

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.name}" = "shared"
    "kubernetes.io/role/elb"              = 1
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.name}" = "shared"
    "kubernetes.io/role/internal-elb"     = 1
  }

  tags = local.tags
}
