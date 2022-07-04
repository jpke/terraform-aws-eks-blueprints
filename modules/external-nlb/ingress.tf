resource "aws_lb" "nginx" {
  name                       = var.cluster_name
  internal                   = false
  load_balancer_type         = "network"
  subnets                    = var.subnets
  enable_deletion_protection = false
}

resource "aws_lb_target_group" "nginx_https" {
  name                 = "${resource.aws_lb.nginx.name}-https"
  port                 = var.https_port
  target_type          = "instance"
  protocol             = "TCP"
  vpc_id               = var.vpc_id
  deregistration_delay = 10
}

resource "aws_lb_target_group" "nginx_http" {
  name                 = "${resource.aws_lb.nginx.name}-http"
  port                 = var.http_port
  target_type          = "instance"
  protocol             = "TCP"
  vpc_id               = var.vpc_id
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
  name = var.hostname
}

resource "aws_route53_record" "argo" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "*.eks-blueprints.${data.aws_route53_zone.main.name}"
  type    = "A"

  alias {
    name                   = aws_lb.nginx.dns_name
    zone_id                = aws_lb.nginx.zone_id
    evaluate_target_health = true
  }
}