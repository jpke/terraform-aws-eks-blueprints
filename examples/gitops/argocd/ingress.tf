resource aws_lb nginx {
  name = "nginx-lb-eks-blueprints"
  internal = false
  load_balancer_type = "network"
  subnets = module.vpc.public_subnets
  enable_deletion_protection = false
}

resource aws_lb_target_group nginx_https {
  name = "${resource.aws_lb.nginx.name}-https"
  port = 32234
  target_type = "instance"
  protocol = "TCP"
  vpc_id = module.vpc.vpc_id
  deregistration_delay = 10
}

resource aws_lb_target_group nginx_http {
  name = "${resource.aws_lb.nginx.name}-http"
  port = 32063
  target_type = "instance"
  protocol = "TCP"
  vpc_id = module.vpc.vpc_id
  deregistration_delay = 10
}

resource "aws_lb_listener" "nginx_https" {
  load_balancer_arn = aws_lb.nginx.arn
  port              = "443"
  protocol          = "TCP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nginx_https.arn
  }
}

resource "aws_lb_listener" "nginx_http" {
  load_balancer_arn = aws_lb.nginx.arn
  port              = "80"
  protocol          = "TCP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nginx_http.arn
  }
}

data "aws_route53_zone" "main" {
  name = "jpearnest.com"
}

resource "aws_route53_record" "argo" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "*.eks-blueprints.${data.aws_route53_zone.main.name}"
  type    = "A"

  alias {
    name                   = aws_lb.nginx.dns_name
    zone_id                = "Z26RNL4JYFTOTI"
    evaluate_target_health = true
  }
}