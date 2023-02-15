variable "vpc_id" {}
variable "subnet_1a_id" {}
variable "subnet_1c_id" {}

# ====================
# ALB
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
# Target Group
# ====================
resource "aws_lb_target_group" "for_webserver" {
  name     = "for-webserver-lb-tg"
  vpc_id   = var.vpc_id

  port     = 3000
  protocol = "HTTP"
  target_type = "ip"

  # コンテナへの死活監視設定
  health_check {
    path = "/api/healthcheck"
  }
}

# ====================
# Listner
# ====================
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.for_webserver.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.for_webserver.arn
  }
}
/*
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
}*/

# ====================
# Security Group
# ====================
resource "aws_security_group" "alb" {
  name        = "nextjs-alb"
  description = "nextjs alb rule based routing"
  vpc_id      = var.vpc_id
  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "nextjs-integrated-alb"
  }
}

resource "aws_security_group_rule" "alb_http" {
  from_port         = 80 //80から
  to_port           = 3000 //80までアクセス許可
  protocol          = "tcp"
  security_group_id = aws_security_group.alb.id
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}