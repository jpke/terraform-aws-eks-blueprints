# resource "aws_security_group" "nginx" {
#   name        = "${var.cluster_name}_nginx_ingress"
#   description = "Allow inbound traffic"
#   vpc_id      = var.vpc_id

#   ingress {
#     description = "Allow http ingress to nginx http nodeports from public subnets and internet"
#     protocol    = "TCP"
#     from_port   = var.http_port
#     to_port     = var.http_port
#     cidr_blocks      = concat(["0.0.0.0/0"], [for k, v in var.azs : cidrsubnet(var.vpc_cidr, 8, k)])
#   }

#   ingress {
#     description = "Allow ingress to nginx https nodeports from public subnets and internet"
#     protocol    = "TCP"
#     from_port   = var.https_port
#     to_port     = var.https_port
#     cidr_blocks      = concat(["0.0.0.0/0"], [for k, v in var.azs : cidrsubnet(var.vpc_cidr, 8, k)])
#   }

#   ingress {
#     description = "Node to node all ports/protocols"
#     protocol    = "-1"
#     from_port   = 0
#     to_port     = 0
#     self        = true
#   }

#   egress {
#     from_port        = 0
#     to_port          = 0
#     protocol         = "-1"
#     cidr_blocks      = ["0.0.0.0/0"]
#     ipv6_cidr_blocks = ["::/0"]
#   }

#   tags = {
#     Name = "${var.cluster_name}_nginx_ingress"
#   }
# }