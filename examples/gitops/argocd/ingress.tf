data "aws_route53_zone" "main" {
  name = "jpearnest.com"
}

resource "aws_route53_record" "argo" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "*.eks-blueprints.${data.aws_route53_zone.main.name}"
  type    = "A"

  alias {
    name                   = "a74d457117f474f23a5eed9bfee290f3-1bfbfb05e02cf64f.elb.us-east-1.amazonaws.com"
    zone_id                = "Z26RNL4JYFTOTI"
    evaluate_target_health = true
  }
}

# resource aws_lb nginx {
#   name = "nginx_lb_eks_blueprints"
#   internal = false
#   load_balancer_type = "network"
#   subnets = module.vpc.public_subnets
#   enable_deletion_protection = false
# }

# resource aws_lb_target_group nginx_https {
#   name = "${resource.aws_lb.nginx.name}_https"
#   port = 1
#   target_type = "ip"
#   protocol = "TCP"
#   vpc_ip = module.vpc.vpc_id
#   deregistration_delay = 10

# }