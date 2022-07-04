output "security_group_id" {
  value = aws_security_group.nginx.id
}

output "http_tg_arn" {
  value = aws_lb_target_group.nginx_http.arn
}

output "https_tg_arn" {
  value = aws_lb_target_group.nginx_https.arn
}