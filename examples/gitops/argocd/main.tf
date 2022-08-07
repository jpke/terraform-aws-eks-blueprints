provider "aws" {
  region = local.region
}

provider "kubernetes" {
  host                   = module.eks_blueprints.eks_cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks_blueprints.eks_cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
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
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      # This requires the awscli to be installed locally where Terraform is executed
      args = ["eks", "get-token", "--cluster-name", module.eks_blueprints.eks_cluster_id]
    }
  }
}

provider "kubectl" {
  apply_retry_count      = 30
  host                   = module.eks_blueprints.eks_cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks_blueprints.eks_cluster_certificate_authority_data)
  load_config_file       = false

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    # This requires the awscli to be installed locally where Terraform is executed
    args = ["eks", "get-token", "--cluster-name", module.eks_blueprints.eks_cluster_id]
  }
}

data "aws_availability_zones" "available" {}

locals {
  name   = basename(path.cwd)
  region = "us-east-1"

  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)

  http_port  = "32063"
  https_port = "32234"

  domain = "jpearnest.com"
  rancher_domain = "rancher.eks-blueprints.${local.domain}"
  rancher_bootstrapPassword = "initialRancherAdminPassword"

  tags = {
    Blueprint  = local.name
    GithubRepo = "github.com/aws-ia/terraform-aws-eks-blueprints"
  }
}

#---------------------------------------------------------------
# EKS Blueprints
#---------------------------------------------------------------
module "eks_blueprints" {
  source = "../../.."

  cluster_name    = local.name
  cluster_version = "1.22"

  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnets

  managed_node_groups = {
    mg_5 = {
      node_group_name        = "managed-ondemand"
      instance_types         = ["m5.large"]
      subnet_ids             = module.vpc.private_subnets
      create_launch_template = true

      desired_size = 5
      max_size     = 10
      min_size     = 3
    }
  }

  # worker_additional_security_group_ids = [module.external_nlb.security_group_id]
  node_security_group_additional_rules = {
    ingress_nodes_all_tcp = {
      description                   = "Cluster control plane all ports/protocols"
      protocol                      = "-1"
      from_port                     = 0
      to_port                       = 0
      type                          = "ingress"
      source_cluster_security_group = true
    }
    ingress_http_port = {
      description = "Allow http ingress to nginx http nodeports from public subnets and internet"
      protocol    = "TCP"
      from_port   = local.http_port
      to_port     = local.http_port
      cidr_blocks = concat(["0.0.0.0/0"], [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k)])
      type        = "ingress"
    }

    ingress_https_port = {
      description = "Allow ingress to nginx https nodeports from public subnets and internet"
      protocol    = "TCP"
      from_port   = local.https_port
      to_port     = local.https_port
      cidr_blocks = concat(["0.0.0.0/0"], [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k)])
      type        = "ingress"
    }

    ingress_all_self = {
      description = "Node to node all ports/protocols"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      self        = true
      type        = "ingress"
    }
    egress_all = {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      type        = "egress"
    }
  }

  tags = local.tags
}

module "eks_blueprints_kubernetes_addons" {
  source = "../../../modules/kubernetes-addons"

  eks_cluster_id       = module.eks_blueprints.eks_cluster_id
  eks_cluster_endpoint = module.eks_blueprints.eks_cluster_endpoint
  eks_oidc_provider    = module.eks_blueprints.oidc_provider
  eks_cluster_version  = module.eks_blueprints.eks_cluster_version

  enable_argocd = true
  argocd_helm_config = {
    values = [templatefile("${path.module}/argocd_values.yaml", {
      hostname = "argo.eks-blueprints.${local.domain}"
    })]
  }
  argocd_manage_add_ons = true # Indicates that ArgoCD is responsible for managing/deploying add-ons
  argocd_applications = {}
  # argocd_applications = {
  #   addons = {
  #     path               = "chart"
  #     repo_url           = "https://github.com/jpke/eks-blueprints-add-ons.git"
  #     target_revision    = "downstream"
  #     add_on_application = true
  #     values = {
  #       repoUrl        = "https://github.com/jpke/eks-blueprints-add-ons.git"
  #       targetRevision = "downstream"
  #       ingressInitialization = {
  #         enable       = true
  #         email        = "jp@jpearnest.com"
  #         http_tg_arn  = "${module.external_nlb.http_tg_arn}"
  #         https_tg_arn = "${module.external_nlb.https_tg_arn}"
  #       }
  #       rancher = {
  #         enable   = true
  #         bootstrapPassword = local.rancher_bootstrapPassword
  #         hostname = local.rancher_domain
  #         ingress = {
  #           extraAnnotations = {
  #             "kubernetes.io/ingress.class" = "nginx"
  #           }
  #           tls = {
  #             source : "letsEncrypt"
  #           }
  #         }
  #         letsEncrypt = {
  #           email = "jp@jpearnest.com"
  #           ingress = {
  #             class = "nginx"
  #           }
  #         }
  #       }
  #     }
  #   }
  #   # workloads = {
  #   #   path               = "envs/dev"
  #   #   # repo_url           = "https://github.com/aws-samples/eks-blueprints-workloads.git"
  #   #   repo_url           = "https://github.com/jpke/eks-blueprints-workloads.git"
  #   #   add_on_application = false
  #   # }
  # }

  # Add-ons
  enable_aws_for_fluentbit            = true
  enable_cert_manager                 = true
  enable_cluster_autoscaler           = true
  enable_aws_load_balancer_controller = true
  enable_metrics_server               = true
  enable_argo_rollouts                = true
  enable_ingress_nginx                = true
  enable_rancher                      = true

  tags = local.tags

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
    "kubernetes.io/cluster/rancher-created" = "shared"
    "kubernetes.io/cluster/${local.name}" = "shared"
    "kubernetes.io/role/elb"              = 1
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.name}" = "shared"
    "kubernetes.io/role/internal-elb"     = 1
  }

  tags = local.tags
}


module "external_nlb" {
  source = "../../../modules/external-nlb"

  vpc_id       = module.vpc.vpc_id
  vpc_cidr     = local.vpc_cidr
  azs          = local.azs
  subnets      = module.vpc.public_subnets
  hostname     = local.domain
  http_port    = local.http_port
  https_port   = local.https_port
  cluster_name = local.name
}

module "rancher" {
  source = "../../../modules/rancher"

  name = local.name
  domain = "https://${local.rancher_domain}"
  bootstrapPassword = local.rancher_bootstrapPassword

  # users = {
  #   test-user = {
  #     clusters = [
  #       "one"
  #     ]
  #   }
  # }

  # clusters = {
  #   one = {
  #     name = "rancher-created"
  #     region = local.region
  #     kubernetes_version = "1.22"
  #     securityGroups = [module.eks_blueprints.worker_node_security_group_id]
  #     subnets = module.vpc.private_subnets
  #   }
  # }

  # gitrepos = {
  #   helm = {
  #     namespace = "fleet-default"
  #     branch = "downstream"
  #     paths = "- single-cluster/helm"
  #     repo = "https://github.com/jpke/fleet-examples.git"
  #     targetNamespace = ""
  #     clusters = [
  #       "one"
  #     ]
  #   }
  # }
}