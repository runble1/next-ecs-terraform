variable "vpc_id" {}
variable "subnet_1a_id" {}
variable "subnet_1c_id" {}

# ====================
#
# ALB
#
# ====================
resource "aws_lb" "for_webserver" {
  name               = "webserver-alb"
  internal           = false
  load_balancer_type = "application"

  security_groups = [
    aws_security_group.alb.id
  ]

  subnets = [
    var.subnet_1a_id,
    var.subnet_1c_id
  ]
}

# ====================
#
# Security Group
#
# ====================
resource "aws_security_group" "alb" {
  name   = "alb"
  vpc_id = var.vpc_id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ====================
#
# Listner
#
# ====================
resource "aws_lb_listener" "for_webserver" {
  load_balancer_arn = aws_lb.for_webserver.arn
  port              = "80"
  protocol          = "HTTP"
  #certificate_arn   = aws_acm_certificate.example.arn #証明書
  #ssl_policy        = "ELBSecurityPolicy-2016-08"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.for_webserver.arn
  }
}

resource "aws_lb_listener_rule" "forward" {
  listener_arn = aws_lb_listener.for_webserver.arn
  priority     = 99

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.for_webserver.arn
  }

  condition {
    path_pattern {
      values = ["/*"]
    }
  }
}

# ====================
#
# Target Group
#
# ====================
resource "aws_lb_target_group" "for_webserver" {
  name     = "for-webserver-lb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path = "/index.html"
  }
}
/*
resource "aws_lb_target_group_attachment" "for_webserver_a" {
  target_group_arn = aws_lb_target_group.for_webserver.arn
  target_id        = aws_instance.a.id
  port             = 80
}
resource "aws_lb_target_group_attachment" "for_webserver_c" {
  target_group_arn = aws_lb_target_group.for_webserver.arn
  target_id        = aws_instance.c.id
  port             = 80
}*/

# ====================
#
# Output
#
# ====================
output "public_dns" {
  value = aws_lb.for_webserver.dns_name
}
