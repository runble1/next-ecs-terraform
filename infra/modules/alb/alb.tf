# ====================
# ALB
# ====================
resource "aws_lb" "for_webserver" {
  name               = "${var.env}-${var.service}-alb"
  internal           = false
  load_balancer_type = "application"

  security_groups = [
    aws_security_group.alb.id
  ]

  subnets = [
    var.subnet_public_1a_id,
    var.subnet_public_1c_id
  ]

  drop_invalid_header_fields = true

  access_logs {
    bucket = aws_s3_bucket.alb_logs.bucket
    #prefix  = "access_logs"
    enabled = true
  }

  tags = {
    Name = "${var.env}-${var.service}-ig"
  }
}

# ====================
# Target Group
# ====================
resource "aws_lb_target_group" "for_webserver" {
  name   = "${var.env}-${var.service}-tg"
  vpc_id = var.vpc_id

  port        = var.app_port
  protocol    = "HTTP"
  target_type = "ip"

  # コンテナへの死活監視設定
  health_check {
    path = "/api/healthcheck"
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "${var.env}-${var.service}-tg"
  }
}

# ====================
# Listener
# ====================
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.for_webserver.arn
  port              = var.lb_port
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.for_webserver.arn
  }

  lifecycle {
    create_before_destroy = true
  }
}

# ====================
# Security Group
# ====================
resource "aws_security_group" "alb" {
  name   = "${var.env}-${var.service}-alb-sg"
  vpc_id = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.env}-${var.service}-alb-sg"
  }
}

resource "aws_security_group_rule" "alb_http" {
  from_port         = var.lb_port
  to_port           = var.lb_port
  protocol          = "tcp"
  security_group_id = aws_security_group.alb.id
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}

# ====================
# Log
# ====================
resource "aws_s3_bucket" "alb_logs" {
  bucket = "${var.env}-${var.service}-alb-logs"

  force_destroy = true
}

resource "aws_s3_bucket_policy" "alb_logs_policy" {
  bucket = aws_s3_bucket.alb_logs.id
  policy = data.aws_iam_policy_document.alb_logs_policy_document.json
}

data "aws_iam_policy_document" "alb_logs_policy_document" {
  statement {
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = [data.aws_elb_service_account.main.arn]
    }
    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.alb_logs.arn}/AWSLogs/${data.aws_caller_identity.self.account_id}/*"]
  }
}